# frozen_string_literal: true

# decidim_awesome 0.14 (Decidim 0.31) adds `link_admin_to_system_admins`, enabled by default:
# an org admin whose email matches a /system admin is logged into /system without a password.
# Not wanted on decidim.swiss (#228); :disabled removes the feature completely.
Decidim::DecidimAwesome.configure do |config|
  config.link_admin_to_system_admins = :disabled
end
