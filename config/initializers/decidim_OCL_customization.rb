# frozen_string_literal: true

Decidim::DiffCell.include DecidimOCL::DiffCell
Decidim::Proposals::ProposalMCell.include DecidimOCL::Proposals::ProposalMCell
Decidim::ParticipatoryProcesses::ProcessMCell.include DecidimOCL::ParticipatoryProcesses::ProcessMCell
Decidim::Proposals::Admin::ProposalNoteCreatedEvent.prepend DecidimOCL::Proposals::Admin::ProposalNoteCreatedEvent