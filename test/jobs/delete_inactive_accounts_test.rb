# frozen_string_literal: true

require 'test_helper'
require 'factory_bot_rails'
require 'decidim/core/test/factories'

# Inactive-account deletion runs only for the organizations listed in DELETE_INACTIVE_ACCOUNTS_ORGANIZATION_IDS (#228).
class DeleteInactiveAccountsTest < ActiveJob::TestCase
  include FactoryBot::Syntax::Methods

  setup do
    @luzern = create(:organization, tenant_type: 'dialogluzern', available_locales: %w[de], default_locale: 'de')
    @winterthur = create(:organization, tenant_type: 'winterthur', available_locales: %w[de], default_locale: 'de')
    # Like gemeinsamer.space on PROD: inactive, but with the same tenant_type as an active tenant.
    @inactive = create(:organization, tenant_type: 'winterthur', available_locales: %w[de], default_locale: 'de')
  end

  def with_env(value)
    old = ENV.fetch('DELETE_INACTIVE_ACCOUNTS_ORGANIZATION_IDS', nil)
    ENV['DELETE_INACTIVE_ACCOUNTS_ORGANIZATION_IDS'] = value
    yield
  ensure
    ENV['DELETE_INACTIVE_ACCOUNTS_ORGANIZATION_IDS'] = old
  end

  def enqueued_organizations
    enqueued_jobs.select { _1['job_class'] == 'Decidim::DeleteInactiveParticipantsJob' }
                 .map { GlobalID::Locator.locate(_1['arguments'].first['_aj_globalid']) }
  end

  def test_only_listed_organizations
    with_env("#{@luzern.id}, #{@winterthur.id}") { DeleteInactiveAccounts.perform_now }

    assert_equal [@luzern, @winterthur].sort_by(&:id), enqueued_organizations.sort_by(&:id)
  end

  def test_nothing_without_tenants
    with_env(nil) { DeleteInactiveAccounts.perform_now }

    assert_empty enqueued_organizations
  end
end
