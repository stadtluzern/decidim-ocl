# frozen_string_literal: true

# This migration comes from decidim_initiatives (originally 20200514102631)
# This file has been modified by `decidim upgrade:migrations` task on 2026-11-07 21:56:37 UTC
class AddAreaEnabledOptionToInitiatives < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_initiatives_types, :area_enabled, :boolean, null: false, default: false
  end
end
