# frozen_string_literal: true

require_relative '20200824145255_create_decidim_calendar_external_events.decidim_calendar'

# This migration reverts the original migration: 20200824145255
class RevertDecidimCalendar < ActiveRecord::Migration[5.2]
  def change
    revert CreateDecidimCalendarExternalEvents
  end
end
