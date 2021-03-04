# frozen_string_literal: true

Decidim::System::UpdateOrganizationForm.class_eval do
  def encrypted_smtp_settings
    smtp_settings[:from] = set_from

    smtp_settings.merge(encrypted_password: Decidim::AttributeEncryptor.encrypt(@password))
  end

  def set_from
    return smtp_settings[:from_email] if smtp_settings[:from_label].blank?

    "#{smtp_settings[:from_label]} <#{smtp_settings[:from_email]}>"
  end
end
