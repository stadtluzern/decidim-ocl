# frozen_string_literal: true

class GenerateReminders < CronJob
  self.cron_expression = '4 0 * * *'

  def perform
    Rake::Task['decidim:reminders:all'].invoke
  end
end
