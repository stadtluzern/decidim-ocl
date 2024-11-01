# frozen_string_literal: true

require_relative '../../lib/customization_output'

INCLUDES = [
  [Decidim::DiffCell,                             DecidimOCL::DiffCell],
  [Decidim::Proposals::ProposalMCell,             DecidimOCL::Proposals::ProposalMCell],
  [Decidim::ParticipatoryProcesses::ProcessMCell, DecidimOCL::ParticipatoryProcesses::ProcessMCell],
  [Decidim::Comments::CommentActivityCell,        DecidimOCL::Comments::CommentActivityCell],
  [Decidim::Proposals::PublishProposalEvent,      DecidimOCL::Proposals::PublishProposalEvent]
].freeze

PREPENDS = [
  [Decidim::ApplicationMailer,                                  DecidimOCL::ApplicationMailer],
  [Decidim::Proposals::Admin::ProposalNoteCreatedEvent,         DecidimOCL::Proposals::Admin::ProposalNoteCreatedEvent],
  [Decidim::Forms::AnswerQuestionnaire,                         DecidimOCL::Forms::AnswerQuestionnaire],
  [Decidim::Meetings::ContentBlocks::UpcomingMeetingsCell,      DecidimOCL::Meetings::ContentBlocks::UpcomingMeetingsCell],
  [Decidim::OrganizationLogoUploader,                           DecidimOCL::OrganizationLogoUploader],
  [Decidim::ParticipatoryProcesses::ParticipatoryProcessHelper, DecidimOCL::ParticipatoryProcesses::ParticipatoryProcessHelper],
].freeze

OVERRIDE_PATHS = ['app/overrides'].freeze

def load_customizations
  ignored = ignore_override_paths(OVERRIDE_PATHS)

  disabled = ENV.fetch('DISABLE_CUSTOMIZATION', '')
  return if disabled.in? %w[true t 1]

  disabled = disabled.split(',')

  included = load_includes(INCLUDES, disabled)
  prepended = load_prepends(PREPENDS, disabled)
  overridden = load_overrides(ignored, disabled)

  CustomizationOutput.puts_and_log(includes: included, prepends: prepended, overrides: overridden)
end

def load_includes(includes, disabled)
  includes.each do |base, addition|
    next if addition.in?(disabled)

    base.include addition
  end
end

def load_prepends(prepends, disabled)
  prepends.each do |base, addition|
    next if addition.in?(disabled)

    base.prepend addition
  end
end

def ignore_override_paths(paths)
  paths
    .map { |p| Pathname.new(p) }
    .each { |p| Rails.autoloaders.main.ignore(p) }
end

def load_overrides(paths, disabled)
  paths =
    paths
    .map { |p| p.glob('**/*_override.rb') }
    .flatten
    .map { |p| p.expand_path.to_s }
    .reject { |p| p.in? disabled }

  Rails.application.config.after_initialize do
    paths.each { |override| load override }
  end

  paths
end

load_customizations

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
  Decidim::Proposals::ProposalWizardCreateStepForm.include(DecidimOCL::Proposals::ProposalWizardCreateStepFormOverride)
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
