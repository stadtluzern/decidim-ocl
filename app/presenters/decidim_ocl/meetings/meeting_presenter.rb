# frozen_string_literal: true

module DecidimOCL
  module Meetings
    # Overwrites the MeetingPresenter module to use first image from text
    module MeetingPresenter
      def image_path
        return nil unless meeting

        Nokogiri::HTML
          .parse(translated_attribute(meeting.description))
          .css('img')
          .first
          &.attr('src')
      end
    end
  end
end
