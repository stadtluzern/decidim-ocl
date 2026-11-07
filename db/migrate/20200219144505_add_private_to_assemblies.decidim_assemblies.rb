# frozen_string_literal: true

# This migration comes from decidim_assemblies (originally 20180124083729)
# This file has been modified by `decidim upgrade:migrations` task on 2026-11-07 21:56:36 UTC
class AddPrivateToAssemblies < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_assemblies, :private_space, :boolean, default: false
  end
end
