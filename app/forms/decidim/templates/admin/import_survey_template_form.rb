# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      # This class holds a Form to import a survey_template.
      class ImportSurveyTemplateForm < Decidim::Form
        attribute :survey_template_upload, Decidim::Attributes::Blob

        validates :survey_template_upload, presence: true
        validate :file_must_be_json

        alias organization current_organization

        def file_must_be_json
          content_type = survey_template_upload.content_type
          return if content_type == 'application/json'

          errors.add(
            :survey_template_upload,
            :invalid_filetype,
            message: I18n.t('decidim.templates.admin.questionnaire_templates.validation.not_json')
          )
        end
      end
    end
  end
end
