# frozen_string_literal: true

Decidim::DiffCell.include DecidimOCL::DiffCell
Decidim::Proposals::ProposalMCell.include DecidimOCL::Proposals::ProposalMCell
Decidim::ParticipatoryProcesses::ProcessMCell.include DecidimOCL::ParticipatoryProcesses::ProcessMCell
Decidim::Proposals::Admin::ProposalNoteCreatedEvent.prepend DecidimOCL::Proposals::Admin::ProposalNoteCreatedEvent

module Decidim
  module Map
    module Provider
      module DynamicMap
        autoload :GisLuzern, "decidim/map/provider/dynamic_map/gis_luzern"
      end
    end
  end
end
