# frozen_string_literal: true

module DecidimOCL
  module Comments
    # A cell to display when a comment has been created.
    module CommentActivityCell
      def root_commentable_title
        renderer = Decidim::ContentRenderers::HashtagRenderer.new(super)
        renderer.render(links: false)
      end
    end
  end
end
