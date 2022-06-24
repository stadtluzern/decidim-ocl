# frozen_string_literal: true

# Override
# --------
# Why it happens:
# Sometimes model.photo is undefined, also we want default images
#
# How we fix it:
# We return the default image if there is no photo or
# if there is a NoMethodError

Decidim::Meetings::MeetingMCell.module_eval do
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
  rescue NoMethodError
    0
  end
end
