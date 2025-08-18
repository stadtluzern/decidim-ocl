# frozen_string_literal: true

class SendNotificationMailDigestDaily < CronJob
  self.cron_expression = '5 0 * * *'

  def perform
    Rake::Task['decidim:mailers:notifications_digest_daily'].invoke
  end
end

