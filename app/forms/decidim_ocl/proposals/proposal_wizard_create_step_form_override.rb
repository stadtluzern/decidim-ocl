# frozen_string_literal: true

# Recreate validations to take into account custom fields and ignore the length limit in proposals
module DecidimOCL
  module Proposals
    module ProposalWizardCreateStepFormOverride
      extend ActiveSupport::Concern

      included do
        clear_validators!
        puts Decidim::Proposals::ProposalWizardCreateStepForm.validators.inspect

        validates :title, presence: true
        validates :title, length: { in: 3..150 }
        validates :body, presence: false, unless: ->(form) { form.override_validations? }
        validates :body, proposal_length: {
          minimum: 0,
          maximum: ->(record) { record.override_validations? ? 0 : record.component.settings.proposal_length }
        }

        validate :body_is_not_bare_template, unless: ->(form) { form.override_validations? }
      end
    end
  end
end
