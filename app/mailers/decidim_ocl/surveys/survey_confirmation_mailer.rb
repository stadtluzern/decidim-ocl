# frozen_string_literal: true

module DecidimOCL
  module Surveys
    # A custom mailer for sending notifications to survey admins when users fill the survey.
    module SurveyConfirmationMailer
      private

      def add_file_with_responses(responses)
        export_name = t('decidim.surveys.survey_confirmation_mailer.export_name')
        serializer = Decidim::Forms::UserResponsesSerializer

        export_data = export_file(responses, serializer)

        filename = export_data.filename(export_name)
        filename_without_extension = export_data.filename(export_name, extension: false)

        attachments["#{filename_without_extension}.zip"] =
          ::Decidim::FileZipper.new(filename, export_data.read).zip
      end

      def export_file(responses, serializer)
        Decidim::Exporters::FormPDF.new(responses, serializer).export
      rescue StandardError
        Decidim::Exporters::CSV.new(responses, serializer).export
      end
    end
  end
end
