# frozen_string_literal: true

# This migration comes from decidim_initiatives (originally 20220527130640)
# This file has been modified by `decidim upgrade:migrations` task on 2026-11-07 21:56:37 UTC
class CreateDecidimInitiativesSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_initiatives_settings do |t|
      t.string :initiatives_order, default: "random"
      t.references :decidim_organization, foreign_key: true, index: true
    end
  end
end
