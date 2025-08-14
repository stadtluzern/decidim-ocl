#!/usr/bin/env ruby
# frozen_string_literal: true

exec('/usr/bin/env', 'rails', 'runner', $PROGRAM_NAME, *ARGV) unless defined?(Rails)

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'rainbow'
end

# Prepare the Database to work well locally
class DevEnv
  require 'rainbow/refinement'
  using Rainbow

  def self.run = new.run

  def run
    puts "\n\n"
    localize_hosts
    reset_password_timers
    remove_mail_settings
  end

  def localize_hosts
    Decidim::Organization.all.each do |org|
      old_host = org.host
      parts = old_host.split('.')
      new_host = "#{parts[..-2].join('.')}.local"

      print "−".white.bright + " Changing '#{old_host}' to '#{new_host}'...\r"
      org.update_attribute(:host, new_host)

      puts "✔".green.bright + " Changed host '#{old_host}' to '#{new_host}'!"
    rescue StandardError => e
      puts "✘ Failed!".red.bright + " Error: #{e.message}"
    end
  end

  def reset_password_timers
    print "−".white.bright + " Reseting all :password_updated_at fields\r"

    # rubocop:disable Rails/SkipsModelValidations
    Decidim::User.update_all(password_updated_at: DateTime.now)
    # rubocop:enable Rails/SkipsModelValidations

    puts "✔".green.bright + " Resetted all :password_updated_at fields"
  end

  # This is needed so tools like mailcatcher work
  def remove_mail_settings(smtp_settings=nil)
    print "−".white.bright + " Reseting all :smtp_settings fields\r"

    smtp_settings ||= {}
    Decidim::Organization.update_all(smtp_settings: smtp_settings)

    puts "✔".green.bright + " Resetted all :smtp_settings fields"
  end
end

DevEnv.run
