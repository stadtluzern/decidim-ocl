# frozen_string_literal: true

module DecidimOCL
  module Proposals
    module Admin
      module ProposalNoteCreatedEvent
        def admin_proposal_info_url
          params = resource.component.mounted_params

          if resource.participatory_space.is_a? ::Decidim::Assembly
            params[:participatory_process_slug] = params.delete(:assembly_slug)
          end

          decidim_admin_participatory_process_proposals.proposal_url(resource, params)
        end
      end
    end
  end
end
