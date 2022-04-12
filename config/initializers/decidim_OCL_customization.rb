# frozen_string_literal: true

Decidim::DiffCell.include DecidimOCL::DiffCell
Decidim::Proposals::ProposalMCell.include DecidimOCL::Proposals::ProposalMCell
Decidim::ParticipatoryProcesses::ProcessMCell.include DecidimOCL::ParticipatoryProcesses::ProcessMCell
Decidim::Proposals::Admin::ProposalNoteCreatedEvent.prepend DecidimOCL::Proposals::Admin::ProposalNoteCreatedEvent
Decidim::Forms::AnswerQuestionnaire.prepend DecidimOCL::Forms::AnswerQuestionnaire
Decidim::Assemblies::AssemblyMCell.prepend DecidimOCL::Assemblies::AssemblyMCell
Decidim::Meetings::MeetingMCell.prepend DecidimOCL::Meetings::MeetingMCell
Decidim::Meetings::MeetingPresenter.prepend DecidimOCL::Meetings::MeetingPresenter
Decidim::Meetings::ContentBlocks::UpcomingEventsCell.prepend DecidimOCL::Meetings::ContentBlocks::UpcomingEventsCell
Decidim::Initiatives::Admin::Permissions.prepend DecidimOCL::Initiatives::Admin::Permissions

# Setup a controller hook to setup the sms gateway before the
# request is processed. This is done through a notification to
# get access to the `current_*` environment variables within
# Decidim. Taken and adapted from the term_customizer module.
ActiveSupport::Notifications.subscribe 'start_processing.action_controller' do |_name, _started, _finished, _unique_id, data|
  DecidimOCL::Verifications::Sms::AspsmsGateway.organization = data[:headers].env['decidim.current_organization']
end

module Decidim
  module Map
    module Provider
      module DynamicMap
        autoload :GisLuzern, 'decidim/map/provider/dynamic_map/gis_luzern'
      end
    end
  end
end
