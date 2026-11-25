# frozen_string_literal: true

#  Decidim Luzern Override
#
#  Created at: 2026-01-14
#  Author: Thomas Burkhalter
#
#  Original:
#    Module: decidim-proposals
#    File: app/cells/decidim/proposals/proposal_metadata_cell.rb
#
#  Why?:
#    During search, there are currently results without a proposal state,
#    so the css_style call fails. This seems to be an oversight,
#    since the title was safe navigated.
#
#    So we wait until it errors, then we use the safe navigator instead.

module DecidimOCL
  module Proposals
    # This cell renders metadata for an instance of a Proposal
    module ProposalMetadataCell
      def state_item
        super
      rescue NoMethodError
        {
          text: content_tag(
            :span,
            translated_attribute(model.proposal_state&.title),
            class: "label",
            style: model.proposal_state&.css_style
          )
        }
      end
    end
  end
end
