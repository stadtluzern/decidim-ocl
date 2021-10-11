# frozen_string_literal: true

module LastBlogPostsHelper
  def blog_image_src(post)
    return post.photos.sort_by(&:weight).first.url if post.photos.count > 0
    'organization-default-image.png'
  end
end
