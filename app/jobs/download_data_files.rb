# frozen_string_literal: true

class DownloadDataFiles < CronJob
  self.cron_expression = '0 0 * * *'

  def perform
    Rake::Task['decidim:delete_download_your_data_files'].invoke
  end
end
