# frozen_string_literal: true

module DecidimOCL
  module Surveys
    # A custom mailer for sending notifications to survey admins when users fill the survey.
    class SurveyAnsweredMailer < Decidim::ApplicationMailer
      include Decidim::TranslationsHelper

      def answered(email, survey, id)
        component = survey.component
        @survey_name = translated_attribute component.name
        @responses_link = Decidim::EngineRouter.admin_proxy(component).survey_response_url(survey, id)

        # need to set the organization for asset resolution to work
        @organization = component.organization

        subject = I18n.t('answered.subject', survey_name: @survey_name,
                                             scope: 'decidim_ocl.surveys.survey_answered_mailer')
        mail(to: email, subject: subject)
      end
    end
  end
end
