# frozen_string_literal: true

# Deletes participants inactive for longer than Decidim's inactivity period
# (DECIDIM_DELETE_INACTIVE_USERS_AFTER_DAYS, Decidim default 365, decidim.swiss 1095;
# warning mails 30 and 7 days before).
#
# Only for the organizations listed in DELETE_INACTIVE_ACCOUNTS_ORGANIZATION_IDS (comma-separated ids,
# set per overlay in the deployment repo, ids differ per environment); without it the job is not
# scheduled and does nothing. Ids, not tenant_type: inactive organizations share tenant types with
# active ones. #228 (C1): all four tenants, 3 years.
class DeleteInactiveAccounts < CronJob
  self.cron_expression = '0 0 * * *'

  def self.organization_ids
    ENV.fetch('DELETE_INACTIVE_ACCOUNTS_ORGANIZATION_IDS', '').split(',').map(&:strip).compact_blank.map(&:to_i)
  end

  def self.schedule
    super if organization_ids.any?
  end

  def perform # rubocop:disable Naming/PredicateMethod -- ActiveJob#perform, returns true for CronJob
    return true if self.class.organization_ids.empty?

    # Same guard as decidim:participants:delete_inactive_participants, which runs every tenant.
    if Decidim.delete_inactive_users_after_days < Decidim.minimum_inactivity_period
      raise "Inactivity period below Decidim's minimum of #{Decidim.minimum_inactivity_period} days"
    end

    Decidim::Organization.where(id: self.class.organization_ids).find_each do |organization|
      Decidim::DeleteInactiveParticipantsJob.perform_later(organization)
    end
    true
  end
end
