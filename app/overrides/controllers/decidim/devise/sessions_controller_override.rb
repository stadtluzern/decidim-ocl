# frozen_string_literal: true

Decidim::Devise::SessionsController.class_eval do
  def first_login_and_not_authorized?(user)
    # Skip verification prompt on first login
    false
  end
end
