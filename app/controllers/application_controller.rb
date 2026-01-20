# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_sentry_context

  private

  def set_sentry_context
    return unless ENV['GLITCHTIP_DSN']

    commit = ENV['BUILD_COMMIT']
    project = ENV['PROJECT'] || ENV['RAILS_DB_NAME']
    customer = ENV['CUSTOMER'] || project&.split('_')[1]
    
    Sentry.set_tags(commit: commit) if commit
    Sentry.set_tags(project: project) if project
    Sentry.set_tags(customer: customer) if customer

    key = session['warden.user.user.key'].presence
    user = Decidim::User.serialize_from_session(*key)

    Sentry.set_user(
      id: user.try(:id),
      username: user.try(:name),
      email: user.try(:email)
    )

    # Capture users locale
    Sentry.set_tags(locale: session['user_locale'])
  end
end
