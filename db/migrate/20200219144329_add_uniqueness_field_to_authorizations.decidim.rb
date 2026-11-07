# frozen_string_literal: true

# This migration comes from decidim (originally 20170117142904)
# This file has been modified by `decidim upgrade:migrations` task on 2026-11-07 21:56:36 UTC
class AddUniquenessFieldToAuthorizations < ActiveRecord::Migration[5.0]
  def change
    change_table :decidim_authorizations do |t|
      t.string :unique_id, null: true
    end
  end
end
