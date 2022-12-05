# frozen_string_literal: true

class AddAspsmsCredentialsToOrganization < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_organizations, :aspsms_user_key, :string
    add_column :decidim_organizations, :aspsms_password, :string
  end
end
