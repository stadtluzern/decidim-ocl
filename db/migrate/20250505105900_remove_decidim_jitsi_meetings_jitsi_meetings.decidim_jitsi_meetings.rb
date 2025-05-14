# This migration comes from decidim_jitsi_meetings (originally 20200406135458)
class RemoveDecidimJitsiMeetingsJitsiMeetings < ActiveRecord::Migration[5.2]
  require_relative '20210121143051_create_decidim_jitsi_meetings_jitsi_meetings.decidim_jitsi_meetings'

  def change
    revert CreateDecidimJitsiMeetingsJitsiMeetings
  end
end
