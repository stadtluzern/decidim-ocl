# frozen_string_literal: true

module DecidimOCL
  module System
    module UpdateOrganization
      def save_organization
        organization.map_config = form.map_config
        organization.tenant_type = form.tenant_type
        organization.aspsms_user_key = form.aspsms_user_key
        organization.aspsms_password = form.aspsms_password
        super
      end
    end
  end
end
