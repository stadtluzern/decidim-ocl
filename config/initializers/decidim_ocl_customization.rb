# frozen_string_literal: true

require_relative '../../lib/decidim_customization'
require_relative '../../lib/puzzle_rails_pry_prompt'

# rubocop:disable Metrics/BlockLength, Lint/ConstantDefinitionInBlock

Rails.application.config.to_prepare do
  PuzzleRailsPryPrompt.set_prompt

  INCLUDES = [].freeze

  PREPENDS = [
    # [Decidim::System::RegisterOrganization, DecidimOCL::System::RegisterOrganization],
    [Decidim::System::UpdateOrganization,                   DecidimOCL::System::UpdateOrganization],
    # [Decidim::GuestMeetingRegistration::CreateRegistration, DecidimOCL::GuestMeetingRegistration::CreateRegistration],
    [Decidim::Surveys::SurveyConfirmationMailer,            DecidimOCL::Surveys::SurveyConfirmationMailer],
    [Decidim::Proposals::ProposalMetadataCell,              DecidimOCL::Proposals::ProposalMetadataCell]
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
    # Decidim::Proposals::ProposalWizardCreateStepForm.include(DecidimOCL::Proposals::ProposalWizardCreateStepFormOverride)
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

  ActiveSupport::Notifications.subscribe('decidim.forms.answer_questionnaire:after') do |event_name, data|
    Rails.logger.info "#{event_name} Received!"
    questionnaire = data[:resource]
    has_component = questionnaire.questionnaire_for.respond_to? :component
    next unless has_component

    component = questionnaire.questionnaire_for.component
    next unless component.manifest_name == 'surveys'

    email = component.try(:settings).try(:notified_email)
    id = data[:extra][:session_token]

    DecidimOCL::Surveys::SurveyAnsweredMailer.answered(email, component, id).deliver_now if email.present?
  end

  # Decidim Luzern Override
  #
  # Created at: 2026-02-17
  # Author: Thomas Burkhalter
  #
  # Original: Not applicable
  #
  # Why?:
  #   On User creation, set a default close_meeting_reminder setting,
  #   that does not spam everyone
  ActiveSupport::Notifications.subscribe(/sql.active_record/) do |event|
    user =
      case event.payload[:name]
      when 'Decidim::User Create'
        event.payload[:binds]
             .select { %w[email decidim_organization_id].include?(_1.name) }
             .to_h { [_1.name, _1.value] }
             .merge({ admin: true })
             .then { Decidim::User.find_by(_1) }
      when /Decidim::.*UserRole Create/
        data = event.payload[:binds].to_h { [_1.name.to_sym, _1.value] }

        Decidim::User.find(data[:decidim_user_id]) if data[:role] == 'admin'
      end

    next unless user

    Rails.logger.info "#{event.payload[:name]} Received! Updating default close_meeting_reminder"

    user.notification_settings['close_meeting_reminder'] ||= '0'
    user.save! if user.changed?
  end
end

# rubocop:enable Metrics/BlockLength, Lint/ConstantDefinitionInBlock
