# frozen_string_literal: true

class ChangeActiveStepInProcesses < CronJob
  self.cron_expression = '*/15 * * * *'

  def perform
    Rake::Task['decidim_participatory_processes:change_active_step'].invoke
  end
end
