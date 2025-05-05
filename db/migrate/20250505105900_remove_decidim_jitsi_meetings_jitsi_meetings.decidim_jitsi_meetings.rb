# This migration comes from decidim_jitsi_meetings (originally 20200406135458)
class RemoveDecidimJitsiMeetingsJitsiMeetings < ActiveRecord::Migration[5.2]
  def change
    revert CreateDecidimJitsiMeetingsJitsiMeetings
  end
end
