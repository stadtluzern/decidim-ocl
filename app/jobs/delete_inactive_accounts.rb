# frozen_string_literal: true

# Deletes participants inactive for longer than Decidim's inactivity period
# (DECIDIM_DELETE_INACTIVE_USERS_AFTER_DAYS, Decidim default 365; warning mails 30 and 7 days before).
#
# Only for the tenants listed in DELETE_INACTIVE_ACCOUNTS_TENANT_TYPES (comma-separated tenant_type,
# e.g. "dialogluzern,winterthur"); without it the job is not scheduled and does nothing. Decided per
# tenant in #228 (open questions C1): Luzern and Winterthur yes, deinklima and Köniz no.
class DeleteInactiveAccounts < CronJob
  self.cron_expression = '0 0 * * *'

  def self.tenant_types
    ENV.fetch('DELETE_INACTIVE_ACCOUNTS_TENANT_TYPES', '').split(',').map(&:strip).compact_blank
  end

  def self.schedule
    super if tenant_types.any?
  end

  def perform # rubocop:disable Naming/PredicateMethod -- ActiveJob#perform, returns true for CronJob
    return true if self.class.tenant_types.empty?

    # Same guard as decidim:participants:delete_inactive_participants, which runs every tenant.
    if Decidim.delete_inactive_users_after_days < Decidim.minimum_inactivity_period
      raise "Inactivity period below Decidim's minimum of #{Decidim.minimum_inactivity_period} days"
    end

    Decidim::Organization.where(tenant_type: self.class.tenant_types).find_each do |organization|
      Decidim::DeleteInactiveParticipantsJob.perform_later(organization)
    end
    true
  end
end
