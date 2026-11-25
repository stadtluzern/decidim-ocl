# frozen_string_literal: true

require_relative 'boot'
require 'decidim/rails'
require 'action_cable/engine'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DecidimOCL
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Rails used SHA1 to encrypt attributes before, now it uses SHA256
    # HACK: keep the old SHA1 algorithm so existing encrypted data stays readable
    config.active_support.hash_digest_class = OpenSSL::Digest::SHA1
    config.active_support.key_generator_hash_digest_class = OpenSSL::Digest::SHA1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.autoloader = :zeitwerk

    # This option silences the logging of Redirector related SQL queries in your log file
    # config.redirector.silence_sql_logs = true
  end
end
