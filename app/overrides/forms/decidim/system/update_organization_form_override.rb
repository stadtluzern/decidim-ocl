# frozen_string_literal: true

Decidim::System::UpdateOrganizationForm.class_eval do
  include Decidim::NestedJsonbAttributes

  nested_jsonb_attribute :map_config, [
      [:provider, String],
      ['default_center.lat', Float],
      ['default_center.lng', Float],
      ['map_limits.lat_min', Float],
      ['map_limits.lat_max', Float],
      ['map_limits.lng_min', Float],
      ['map_limits.lng_max', Float]
  ]

  attribute :tenant_type, String

  attribute :aspsms_user_key, String
  attribute :aspsms_password, String

  validates :aspsms_user_key, :aspsms_password, presence: true, if: :sms_verification_active?

  def sms_verification_active?
    available_authorizations.present? && available_authorizations.include?('sms')
  end
end

Decidim::System::RegisterOrganization.prepend DecidimOCL::System::RegisterOrganization
Decidim::System::UpdateOrganization.prepend DecidimOCL::System::UpdateOrganization