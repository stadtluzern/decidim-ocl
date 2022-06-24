# frozen_string_literal: true

module DecidimOCL
  module Meetings
    # Modifications to make the /meetings list more compact
    module MeetingMCell
      include ApplicationHelper

      def has_authors? # rubocop:disable Naming/PredicateName
        false
      end

      def has_image? # rubocop:disable Naming/PredicateName
        true
      end

      def date
        render
      end

      def title
        present(model).title
      end

      private

      def resource_image_path
        model.photo&.url || 'organization-default-image.png'
      rescue NoMethodError
        'organization-default-image.png'
      end

      def followers_count
        if model.respond_to?(:followers_count)
          model.followers_count
        else
          model.followers.count
        end
      end

      def description
        nil
      end

      def statuses
        []
      end

      def has_actions? # rubocop:disable Naming/PredicateName
        false
      end

      def has_badge? # rubocop:disable Naming/PredicateName
        false
      end

      def show_footer_actions?
        false
      end
    end
  end
end
