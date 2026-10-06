# frozen_string_literal: true

require 'rack/attack'
require 'ipaddr'
require_relative '../../lib/rack_attack_helper'

rack = DecidimOCL::RackAttackHelper

Rack::Attack.enabled = rack.enabled?
rack.safelist_ips_from_env
rack.register_s3_redirects
# No 'requests by ip' throttle here: decidim-core registers that name in an
# ActiveSupport::Reloader.to_prepare hook, which runs after this initializer and
# overwrites whatever we set. Tune it via DECIDIM_THROTTLING_MAX_REQUESTS and
# DECIDIM_THROTTLING_PERIOD (minutes) -> config/secrets.yml.
rack.register_allow2ban_filter_from_env 'secure admin logins', 'RACK_ATTACK_FILTER_ADMIN_LOGIN' do |req|
  req.post? && req.path.include?('system')
end

# Logs every match; RACK_ATTACK_DEBUG=true adds filtered request params.
rack.subscribe_to_notifications
