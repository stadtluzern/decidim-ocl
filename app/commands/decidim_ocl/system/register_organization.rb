# frozen_string_literal: true

module DecidimOCL
  module System
    module RegisterOrganization
      def create_organization
        super.tap do |organization|
          organization.update!(
              map_config: form.map_config,
              tenant_type: form.tenant_type,
              aspsms_user_key: form.aspsms_user_key,
              aspsms_password: form.aspsms_password,
          )
        end
      end
    end
  end
end
