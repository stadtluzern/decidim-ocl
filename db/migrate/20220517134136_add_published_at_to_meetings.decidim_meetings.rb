# frozen_string_literal: true

# This migration comes from decidim_meetings (originally 20210413050756)
# This file has been modified by `decidim upgrade:migrations` task on 2026-11-07 21:56:37 UTC
class AddPublishedAtToMeetings < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_meetings_meetings, :published_at, :datetime, index: true
  end
end
