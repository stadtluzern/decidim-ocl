# frozen_string_literal: true

# This migration comes from decidim_initiatives (originally 20200514085422)
# This file has been modified by `decidim upgrade:migrations` task on 2026-11-07 21:56:37 UTC
class AddAreaToInitiatives < ActiveRecord::Migration[5.2]
  def change
    add_reference :decidim_initiatives, :decidim_area, index: true
  end
end
