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
end
