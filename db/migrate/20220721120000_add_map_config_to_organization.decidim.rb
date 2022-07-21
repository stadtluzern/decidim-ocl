# frozen_string_literal: true

class AddMapConfigToOrganization < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_organizations, :map_config, :jsonb, default: {}
  end
end
