# frozen_string_literal: true

module DecidimOCL::Initiatives::Admin
  # Modification to hide the "download signatures" button in an initiative
  module Permissions
    private

    def initiative_admin_user_action?
      if permission_action.subject == :initiative &&
          permission_action.action == :export_pdf_signatures
        return disallow!
      end

      if permission_action.subject == :initiative &&
          permission_action.action == :export_votes
        return disallow!
      end

      super
    end
  end
end
