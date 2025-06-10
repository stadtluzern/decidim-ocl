# frozen_string_literal: true

require_relative '../../lib/decidim_customization'
require_relative '../../lib/puzzle_rails_pry_prompt'

PuzzleRailsPryPrompt.set_prompt

INCLUDES = [
  #[Decidim::Comments::CommentActivityCell,        DecidimOCL::Comments::CommentActivityCell],
  #[Decidim::Proposals::PublishProposalEvent,      DecidimOCL::Proposals::PublishProposalEvent]
].freeze

PREPENDS = [
  #[Decidim::ApplicationMailer,                                  DecidimOCL::ApplicationMailer],
  #[Decidim::Forms::AnswerQuestionnaire,                         DecidimOCL::Forms::AnswerQuestionnaire],
  #[Decidim::Meetings::ContentBlocks::UpcomingMeetingsCell,      DecidimOCL::Meetings::ContentBlocks::UpcomingMeetingsCell],
  #[Decidim::OrganizationLogoUploader,                           DecidimOCL::OrganizationLogoUploader],
  #[Decidim::ParticipatoryProcesses::ParticipatoryProcessHelper, DecidimOCL::ParticipatoryProcesses::ParticipatoryProcessHelper]
].freeze

OVERRIDE_PATHS = [
  'app/overrides'
].freeze

DecidimCustomization.new(
  includes: INCLUDES,
  prepends: PREPENDS,
  overrides: OVERRIDE_PATHS
).log_and_load

# v Specially handled things (here be dragons) v

# Add the Devise custom scope to the Decidim config
# Find all instances with: <% scope = Decidim.config.devise_custom_scope.(@organization) %>
Decidim.config[:devise_custom_scope] = lambda { |org, base = nil|
  base ||= %i[decidim_ocl devise]

  org_scope = (org.tenant_type.presence || 'other').to_sym

  # Ensure that the current tenant is using custom translations for the devise mails
  base + [org_scope] if I18n.t(org_scope, scope: base, default: nil)
}

# Setup a controller hook to setup the sms gateway before the
# request is processed. This is done through a notification to
# get access to the `current_*` environment variables within
# Decidim. Taken and adapted from the term_customizer module.
ActiveSupport::Notifications.subscribe 'start_processing.action_controller' do |_name, _started, _finished, _unique_id, data|
  DecidimOCL::Verifications::Sms::AspsmsGateway.organization = data[:headers].env['decidim.current_organization']
end

# Override default for surveys
Decidim.find_component_manifest(:surveys).settings(:global).attributes[:clean_after_publish].default = false

# Run this customization late, after decidim awesome has initialized
Rails.application.config.after_initialize do
  #Decidim::Proposals::ProposalWizardCreateStepForm.include(DecidimOCL::Proposals::ProposalWizardCreateStepFormOverride)
end

module Decidim
  module Map
    module Provider
      module DynamicMap
        autoload :Swisstopo, 'decidim/map/provider/dynamic_map/swisstopo'
      end
    end
  end
end
