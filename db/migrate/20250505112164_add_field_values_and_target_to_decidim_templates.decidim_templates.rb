# frozen_string_literal: true
# This migration comes from decidim_templates (originally 20221006055954)

class AddFieldValuesAndTargetToDecidimTemplates < ActiveRecord::Migration[6.0]
  class Template < ApplicationRecord
    self.table_name = :decidim_templates_templates
  end

  def change
    # This migration was modified because we already had the field_values and target columns
    # from an old migration in the decidim_reporting_proposals module. In that module, the migrations
    # have since been deleted, but in our databases the columns are still present.
    # So the most realistic solution which works both in development and production is to
    # add the conditional unless here.
    unless ActiveRecord::Base.connection.column_exists?(:decidim_templates_templates, :field_values)
      add_column :decidim_templates_templates, :field_values, :json, default: {}
    end
    unless ActiveRecord::Base.connection.column_exists?(:decidim_templates_templates, :target)
      add_column :decidim_templates_templates, :target, :string
    end

    reversible do |direction|
      direction.up do
        # rubocop:disable Rails/SkipsModelValidations
        Template.where(templatable_type: "Decidim::Forms::Questionnaire").update_all(target: "questionnaire")
        Template.where(templatable_type: "Decidim::Organization").update_all(target: "user_block")
        # rubocop:enable Rails/SkipsModelValidations
      end
    end
  end
end
