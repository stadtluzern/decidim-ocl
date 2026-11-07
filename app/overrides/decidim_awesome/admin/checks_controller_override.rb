# frozen_string_literal: true

# decidim_awesome's "log into /system as the system admin with my email" action does not check
# `link_admin_to_system_admins` (the setting only hides the button), so an org admin could still
# POST to it. Block it unless the feature is explicitly enabled (it is :disabled in
# config/initializers/decidim_awesome.rb). Security warning in planning.html (#228).
Decidim::DecidimAwesome::Admin::ChecksController.class_eval do
  before_action only: :system_login do
    unless Decidim::DecidimAwesome.enabled?(:link_admin_to_system_admins)
      raise ActionController::RoutingError, 'Not Found'
    end
  end
end
