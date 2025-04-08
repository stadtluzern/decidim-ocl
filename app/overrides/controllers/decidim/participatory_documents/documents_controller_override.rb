# frozen_string_literal: true

# Set a custom pdf_custom_style to make the comment sidebar resizable
# Implemented: 08.04.2025
# Last checked: 08.04.2025

Decidim::ParticipatoryDocuments::DocumentsController.class_eval do
  before_action :pdf_custom_style_with_resize

  def pdf_custom_style_with_resize
    @pdf_custom_style =
      begin
        css = <<~CSS
              <style media="all">
                :root {
                  --box-color: #{document.box_color || "#1E98D7"};
                  --box-color-rgba: #{box_color_as_rgba(document)};
                  --notifications-color-rgba: #{box_color_as_rgba(document, opacity: 60)};
                  --suggestions-modal-color-hsla: #{box_color_as_hsla(document, opacity: 0.95)};
                }

                /* Make PDF comment sidebar resizable */
                #participation-modal.section.active {
                  resize: horizontal;
                }

              </style>
        CSS
        css.html_safe
      end
  end
end
