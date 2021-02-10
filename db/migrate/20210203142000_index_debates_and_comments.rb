# frozen_string_literal: true
# This migration comes from decidim_initiatives (originally 20200827154214)

class IndexDebatesAndComments < ActiveRecord::Migration[5.2]
  def change
    Decidim::Comments::Comment.find_each(&:try_update_index_for_search_resource)
    Decidim::Debates::Debate.find_each(&:try_update_index_for_search_resource)
  end
end
