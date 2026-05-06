# frozen_string_literal: true

class CronJob < ApplicationJob
  class_attribute :cron_expression

  class << self

    def schedule
      set(cron: cron_expression).perform_later unless scheduled?
    end

    def remove
      delayed_job.destroy if scheduled?
    end

    def scheduled?
      delayed_job.present?
    end

    def delayed_job
      Delayed::Job
        .where('handler LIKE ?', "%job_class: #{name}%")
        .where(failed_at: nil) # ignore failed jobs if destroy_failed_jobs == false
        .first
    end
  end

  def run_rake_task(task_name)
    Rails.logger.info "Starting Rake task: #{task_name}"

    # Run via system instead of Rake::Task['...'].invoke to avoid Rake state issues
    success = system({ "RAILS_ENV" => Rails.env }, "bundle exec rake #{task_name}",
      chdir: Rails.root)

    if success
      Rails.logger.info "Successfully completed Rake task: #{task_name}"
    else
      raise "Rake task '#{task_name}' failed with status #{$?.exitstatus}"
    end

    true
  end
end
