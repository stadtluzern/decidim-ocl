# frozen_string_literal: true

# Deletes participants inactive for longer than Decidim's inactivity period.
# Inert unless DECIDIM_DELETE_INACTIVE_USERS_AFTER_DAYS is set (Decidim's own
# default is 365 days, so setting it explicitly is the opt-in).
class DeleteInactiveAccounts < CronJob
  self.cron_expression = '0 0 * * *'

  def self.enabled?
    ENV.key?('DECIDIM_DELETE_INACTIVE_USERS_AFTER_DAYS')
  end

  def self.schedule
    super if enabled?
  end

  def perform
    return true unless self.class.enabled?

    run_rake_task('decidim:participants:delete_inactive_participants')
  end
end
