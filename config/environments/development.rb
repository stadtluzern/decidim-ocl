# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  config.action_controller.perform_caching = if Rails.root.join('tmp', 'caching-dev.txt').exist?
                                               true

                                               # config.cache_store = :memory_store
                                               # config.public_file_server.headers = {
                                               #   'Cache-Control' => "public, max-age=#{2.days.to_i}"
                                               # }
                                             else
                                               false

                                               # config.cache_store = :null_store
                                             end
  memcached_host = ENV['RAILS_MEMCACHED_HOST'] || 'localhost'
  memcached_port = ENV['RAILS_MEMCACHED_PORT'] || '11211'
  config.cache_store = :mem_cache_store, "#{memcached_host}:#{memcached_port}"

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = ENV['ACTIVE_STORAGE_SERVICE']&.to_sym || :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :letter_opener_web

  LetterOpenerWeb.configure do |config|
    config.letters_location = Rails.root.join('tmp/letter_opener')
  end
  config.action_mailer.default_url_options = { port: 3000 }

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.aspsms = {
    user_key: ENV.fetch('ASPSMS_API_USER_KEY', nil),
    password: ENV.fetch('ASPSMS_API_PASSWORD', nil),
    affiliate_id: ENV.fetch('ASPSMS_AFFILIATE_ID', nil),
  }

  # Add allowed hosts and deduplicate them
  hosts = ENV.fetch('RAILS_ALLOWED_HOSTS', '').split(',').map(&:strip)
  host = ENV['RAILS_HOST']
  config.hosts |= hosts if hosts.present?
  config.hosts |= [host] if host.present?

  # TODO Remove after fixing dev
  config.log_level = :info

  config.lograge.enabled = true
  config.lograge.ignore_actions = ['StatusController#health', 'StatusController#readiness']
  config.lograge.custom_payload do |controller|
    {
      host: controller.request.host,
      user_id: controller.current_user.try(:id)
    }
  end
  config.lograge.custom_options = lambda do |event|
    exceptions = %w[controller action format id]
    {
      time: Time.zone.now.utc,
      params: event.payload[:params].except(*exceptions)
    }
  end
end
