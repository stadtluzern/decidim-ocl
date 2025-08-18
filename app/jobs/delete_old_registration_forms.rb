# frozen_string_literal: true

class DeleteOldRegistrationForms < CronJob
  self.cron_expression = '3 0 * * *'

  def perform
    Rake::Task['decidim_meetings:clean_registration_forms'].invoke
  end
end
