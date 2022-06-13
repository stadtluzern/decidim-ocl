# frozen_string_literal: true

require 'active_support/concern'

module DecidimOCL
  module Proposals
    module ProposalMCell
      extend ActiveSupport::Concern

      included do
        def has_image?
          @has_image ||= model.attachments.map(&:image?).any?
        end

        def resource_image_path
          @resource_image_path ||=
            if has_image?
              model.attachments.find_by("content_type like '%image%'").thumbnail_url
            else
              model.component.participatory_space.attached_uploader(:hero_image).path
            end
        end
      end
    end
  end
end
