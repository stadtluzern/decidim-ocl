# frozen_string_literal: true

# Override
# --------
# Why it happens:
# For meetings which have no attached photo, we want to display a default image instead.
# Also, we want to display the number of followers directly on the meeting.
#
# How we fix it:
# We return the default image if there is no photo.
# Also, we implement some logic for calculating the number of followers.

Decidim::Meetings::MeetingMCell.module_eval do
  def resource_image_path
    model.photo&.url || 'organization-default-image.png'
  end

  def followers_count
    if model.respond_to?(:followers_count)
      model.followers_count
    else
      model.followers.count
    end
  end
end
