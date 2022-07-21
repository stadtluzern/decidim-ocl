# frozen_string_literal: true

module DecidimOCL
  module System
    module UpdateOrganization
      def save_organization
        organization.map_config = form.map_config
        super
      end
    end
  end
end
