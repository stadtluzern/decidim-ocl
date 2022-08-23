# frozen_string_literal: true

class AddTenantTypeToOrganization < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_organizations, :tenant_type, :string
  end
end
