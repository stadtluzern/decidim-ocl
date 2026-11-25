# frozen_string_literal: true

#  Decidim Luzern Override
#
#  Created at: 2026-10-08
#  Author: Thomas Burkhalter
#
#  Original:
#    Module: decidim-forms
#    File: app/models/decidim/forms/question.rb
#
#  Why?:
#    The existing relationship wrongly declares the option `inverse_of: :question`
#    instead of :condition_question.
#    Existing solutions target only v0.31/v0.32 of Decidim.
#
#  Why class_eval and not a prepend/include?
#    `has_many` is a class-level macro. Prepends/includes don't work at that level.
#
#  Refs:
#    - decidim-swiss/decidim.swiss#231
#    - https://github.com/decidim/decidim/pull/17321

association = Decidim::Forms::Question.reflect_on_association(:display_conditions_for_other_questions)
return if association.options[:inverse_of] == :condition_question

Decidim::Forms::Question.class_eval do
  has_many :display_conditions_for_other_questions,
           class_name: 'DisplayCondition',
           foreign_key: 'decidim_condition_question_id',
           dependent: :destroy,
           inverse_of: :condition_question
end
