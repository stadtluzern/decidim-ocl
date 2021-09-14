# frozen_string_literal: true

module DecidimOCL
  module Forms
    module AnswerQuestionnaire
      def answer_questionnaire
        super
        if current_component&.manifest_name == 'surveys'
          component = current_component
          survey = @questionnaire.questionnaire_for
          email = survey.try(:component).try(:settings).try(:notified_email)

          if email.present?
            DecidimOCL::Surveys::SurveyAnsweredMailer.answered(email, component).deliver_now
          end
        end
      end
    end
  end
end
