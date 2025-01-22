Decidim::Templates::Admin::QuestionnaireTemplatesController.class_eval do
  def export
    json =
      {
        template: template,
        questionnaire: template.templatable,
        questions: template.templatable.questions
      }.to_json

    id = template.id
    name = template.name[locale.to_s].parameterize.underscore

    send_data(
      json,
      type: 'application/json',
      filename: "template-#{id}-#{name}.json"
    )
  end

  def new_import
    @form = form(Decidim::Templates::Admin::ImportSurveyTemplateForm).instance
  end

  def import
    return error_redirect if survey_form.invalid?

    target_template = Decidim::Templates::Template.create(source_template)
    target_questionnaire = Decidim::Forms::Questionnaire.create(source_questionnaire(target_template))
    source_questions(target_questionnaire)
      .each { Decidim::Forms::Question.create(_1) }

    redirect_to questionnaire_templates_path
  end

  private

  def error_redirect
    binding.pry
    messages =
      survey_form
      .errors[:survey_template_upload]
      .join(', ')

    redirect_to(
      new_import_questionnaire_template_path,
      alert: t('.failed', messages: messages)
    )
  end

  def survey_form
    @survey_form ||=
      form(Decidim::Templates::Admin::ImportSurveyTemplateForm)
        .from_params(params, current_organization: current_organization)
  end

  def survey_source
    @survey_source ||=
      survey_form
      .survey_template_upload
      .open { JSON.parse(_1.read, symbolize_names: true) }
  end

  def source_template
    survey_source[:template]
      .except(*%i[id decidim_organization_id templatable_type templatable_id created_at updated_at])
      .merge(organization: current_organization)
  end

  def source_questionnaire(template)
    survey_source[:questionnaire]
      .except(*%i[id questionnaire_for_type questionnaire_for_id published_at created_at updated_at])
      .merge(questionnaire_for: template, template: template)
  end

  def source_questions(questionnaire)
    survey_source[:questions].map do |question|
      question
        .except(*%i[id decidim_questionnaire_id created_at updated_at])
        .merge(decidim_questionnaire_id: questionnaire.id)
    end
  end
end
