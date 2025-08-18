# frozen_string_literal: true

class InitiativesNotifyProgress < CronJob
  # Notifies progress on published initiatives
  self.cron_expression = '0 8 * * *'

  def perform
    Rake::Task['decidim_initiatives:notify_progress'].invoke
  end
end
