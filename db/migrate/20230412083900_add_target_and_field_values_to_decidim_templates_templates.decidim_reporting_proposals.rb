# frozen_string_literal: true
# This migration comes from decidim_reporting_proposals (originally 20230404103706)

class AddTargetAndFieldValuesToDecidimTemplatesTemplates < ActiveRecord::Migration[6.0]
  def change
    unless ActiveRecord::Base.connection.column_exists?(:decidim_templates_templates, :field_values)
      add_column :decidim_templates_templates, :field_values, :json, default: {}
    end
    unless ActiveRecord::Base.connection.column_exists?(:decidim_templates_templates, :target)
      add_column :decidim_templates_templates, :target, :string
    end
  end
end
