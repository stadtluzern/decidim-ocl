# frozen_string_literal: true

require 'test_helper'
require 'factory_bot_rails'
require 'decidim/core/test/factories'
require 'decidim/forms/test/factories'

#  Regression test for decidim-swiss/decidim.swiss#231:
#  re-saving a display condition must not move it to its condition question.
#  Covered by app/overrides/decidim/forms/question_override.rb
class DisplayConditionOwnershipTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  setup do
    organization = create(:organization, available_locales: %w[de], default_locale: 'de')
    questionnaire = create(:questionnaire, questionnaire_for: organization)
    @source = create(:questionnaire_question, questionnaire:, question_type: 'single_option')
    @option = create(:answer_option, question: @source)
    @conditioned = create(:questionnaire_question, questionnaire:, question_type: 'short_answer')
  end

  def test_resaving_keeps_the_owning_question
    condition = @conditioned.display_conditions.create!(condition_question: @source,
                                                        condition_type: :equal,
                                                        answer_option: @option)

    # as Decidim::Forms::Admin::UpdateQuestionnaire does on every save
    @conditioned.display_conditions.find(condition.id).update!(condition_question: @source)

    condition.reload
    assert_equal @conditioned.id, condition.decidim_question_id
    assert_equal @source.id, condition.decidim_condition_question_id
  end
end
