# frozen_string_literal: true

class SendNotificationMailDigestWeekly < CronJob
  self.cron_expression = '5 0 * * 6'

  def perform
    Rake::Task['decidim:mailers:notifications_digest_weekly'].invoke
  end
end
