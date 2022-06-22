# frozen_string_literal: true

require_relative '../../lib/customization_output'

includes = [
  [Decidim::DiffCell, DecidimOCL::DiffCell],
  [Decidim::Proposals::ProposalMCell, DecidimOCL::Proposals::ProposalMCell],
  [Decidim::ParticipatoryProcesses::ProcessMCell, DecidimOCL::ParticipatoryProcesses::ProcessMCell]
].each { |base, addition| base.include addition }

prepends = [
  [Decidim::Proposals::Admin::ProposalNoteCreatedEvent, DecidimOCL::Proposals::Admin::ProposalNoteCreatedEvent],
  [Decidim::Forms::AnswerQuestionnaire, DecidimOCL::Forms::AnswerQuestionnaire],
  [Decidim::Assemblies::AssemblyMCell, DecidimOCL::Assemblies::AssemblyMCell],
  [Decidim::Meetings::MeetingMCell, DecidimOCL::Meetings::MeetingMCell],
  [Decidim::Meetings::MeetingPresenter, DecidimOCL::Meetings::MeetingPresenter],
  [Decidim::Meetings::ContentBlocks::UpcomingMeetingsCell, DecidimOCL::Meetings::ContentBlocks::UpcomingMeetingsCell],
  # [Decidim::Initiatives::Admin::Permissions, DecidimOCL::Initiatives::Admin::Permissions]
].each { |base, addition| base.prepend addition }

override_path = Pathname.new('app/overrides')
Rails.autoloaders.main.ignore(override_path)

overrides = override_path.glob('**/*_override.rb')
Rails.application.config.after_initialize do
  overrides.each do |override|
    load override.expand_path.to_s
  end
end

CustomizationOutput.puts_and_log(includes: includes, prepends: prepends, overrides: overrides)

# v Specially handled things (here be dragons) v

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
