# frozen_string_literal: true

class InitiativesCheckValidating < CronJob
  # Checks validating initiatives and moves all without changes for a configured time to discarded state
  self.cron_expression = '0 7 * * *'

  def perform
    Rake::Task['decidim_initiatives:check_validating'].invoke
  end
end
