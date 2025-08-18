# frozen_string_literal: true

class ComputeOpenData < CronJob
  self.cron_expression = '2 0 * * *'

  def perform
    Rake::Task['decidim:open_data:export'].invoke
  end
end

