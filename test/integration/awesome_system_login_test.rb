# frozen_string_literal: true

require 'test_helper'
require 'factory_bot_rails'
require 'decidim/core/test/factories'
require 'decidim/system/test/factories'

# decidim_awesome's system_login must not log an org admin into /system (planning.html, security warning).
class AwesomeSystemLoginTest < ActionDispatch::IntegrationTest
  include FactoryBot::Syntax::Methods
  include Devise::Test::IntegrationHelpers

  setup do
    @organization = create(:organization, available_locales: %w[de], default_locale: 'de')
    @admin = create(:user, organization: @organization, locale: 'de')
    # update_columns: the :admin/:confirmed traits re-index the user and trip SearchableResource uniqueness here
    @admin.update_columns(admin: true, confirmed_at: Time.current, admin_terms_accepted_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
    pw = 'Xq7!vLp2#rT9wZk4'
    create(:admin, email: @admin.email, password: pw, password_confirmation: pw)
    host! @organization.host
    sign_in @admin, scope: :user
  end

  def test_system_login_is_blocked
    post '/admin/decidim_awesome/maintenance/checks'

    assert_response :not_found
    get '/system'
    assert_response :redirect, 'must not be signed into /system'
  end
end
