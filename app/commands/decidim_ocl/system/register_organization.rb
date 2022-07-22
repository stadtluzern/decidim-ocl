# frozen_string_literal: true

module DecidimOCL
  module System
    module RegisterOrganization
      def create_organization
        super.tap { |organization| organization.update!(map_config: form.map_config) }
      end
    end
  end
end
