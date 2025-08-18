# frozen_string_literal: true

class InitiativesCheckPublished < CronJob
  # Checks published initiatives and moves to accepted/rejected state depending on the votes collected when the signing period has finished
  self.cron_expression = '30 7 * * *'

  def perform
    Rake::Task['decidim_initiatives:check_published'].invoke
  end
end
