module DecidimOCL
  module Proposals
    module PublishProposalEvent
      def resource_text
        resolve_content_renderers(resource.body)
      end

      def translatable_text
        resolve_content_renderers(resource.body)
      end

      private

      def resolve_content_renderers(content)
        Decidim::ResourcePresenter.new(resource).handle_locales(resource.body, true) do |content|
          [
            Decidim::ContentRenderers::HashtagRenderer,
            Decidim::ContentRenderers::UserRenderer,
            Decidim::ContentRenderers::UserGroupRenderer
          ].each do |renderer_class|
            renderer = renderer_class.new(content)
            content = renderer.render(links: false, extras: true).html_safe
          end
  
          content
        end
      end
    end
  end
end