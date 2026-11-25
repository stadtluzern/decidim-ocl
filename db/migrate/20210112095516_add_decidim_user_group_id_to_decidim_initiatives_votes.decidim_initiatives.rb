# frozen_string_literal: true

# This migration comes from decidim_initiatives (originally 20170928160302)
# This file has been modified by `decidim upgrade:migrations` task on 2026-11-07 21:56:37 UTC
class AddDecidimUserGroupIdToDecidimInitiativesVotes < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_initiatives_votes,
               :decidim_user_group_id, :integer, index: true
  end
end
