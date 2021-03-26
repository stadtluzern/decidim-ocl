# frozen_string_literal: true
# TODO remove this after upgrading to decidim 0.24

require 'active_support/concern'

module DecidimOcl
  module Proposals
    module ProposalsController
      extend ActiveSupport::Concern

      included do
        def preview
          @step = :step_4
          @form = form(::Decidim::Proposals::ProposalForm).from_model(@proposal)
        end
      end
    end
  end
end
