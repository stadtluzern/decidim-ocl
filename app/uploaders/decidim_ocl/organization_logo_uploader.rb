# frozen_string_literal: true

module DecidimOCL
  # Additionally allow SVG as organization logo format
  module OrganizationLogoUploader
    def content_type_allowlist
      %w[image/jpeg image/png image/svg+xml image/gif]
    end

    def extension_allowlist
      %w[jpeg jpg png svg gif]
    end
  end
end
