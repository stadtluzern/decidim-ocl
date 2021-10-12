# frozen_string_literal: true

module LastBlogPostsHelper
  def blog_image_src(post)
    image_from_text = Nokogiri::HTML
        .parse(translated_attribute post.body)
        .css('img')
        .first
        &.attr('src')

    return image_from_text if image_from_text.present?
    return post.photos.sort_by(&:weight).first.url if post.photos.count > 0
    'organization-default-image.png'
  end
end
