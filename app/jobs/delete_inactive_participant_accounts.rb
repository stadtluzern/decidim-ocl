# frozen_string_literal: true

class DeleteInactiveParticipantAccounts < CronJob
  self.cron_expression = '0 0 * * *'

  def perform
    Rake::Task['decidim:participants:delete_inactive_participants'].invoke
  end
end
