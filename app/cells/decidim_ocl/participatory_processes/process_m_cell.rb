# frozen_string_literal: true

require 'active_support/concern'

module DecidimOCL
  module ParticipatoryProcesses
    module ProcessMCell
      extend ActiveSupport::Concern

      included do
        def resource_image_path
          path_for(:hero_image) ||
            path_for(:highlighted_content_banner_image) ||
            default_image
        rescue StandardError
          default_image
        end

        private

        def path_for(key)
          model.attached_uploader(key).path
        end

        def default_image
          org = model.organization&.tenant_type&.presence || 'organization'
          "#{org}-default-image.png"
        end
      end
    end
  end
end
