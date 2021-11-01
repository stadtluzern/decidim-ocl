# frozen_string_literal: true

module DecidimOCL
  module Meetings
    module ContentBlocks
      # Only show events that are today or in the future
      module UpcomingEventsCell
        def upcoming_events
          super.where('start_time >= ?', DateTime.now.beginning_of_day)
        end
      end
    end
  end
end
