# frozen_string_literal: true

require 'active_support/concern'

module DecidimOCL
  module ParticipatoryProcesses
    module ProcessMCell
      extend ActiveSupport::Concern

      included do
        def resource_image_path
          model.attached_uploader(:hero_image).path || default_image
        rescue StandardError
          default_image
        end

        private

        def default_image
          rails_blob_path(current_organization.highlighted_content_banner_image)
        end
      end
    end
  end
end
