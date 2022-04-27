# frozen_string_literal: true

Decidim::Comments::CommentsController.class_eval do
  def create
    enforce_permission_to :create, :comment, commentable: commentable

    form = Decidim::Comments::CommentForm.from_params(
      params.merge(commentable: commentable)
    ).with_context(
      current_organization: current_organization,
      current_component: current_component
    )
    Decidim::Comments::CreateComment.call(form, current_user) do
      on(:ok) do |comment|
        handle_success(comment)
        respond_to do |format|
          format.js { render :create }
        end
      end

      on(:invalid) do
        @error = t("create.error", scope: "decidim.comments.comments")
        respond_to do |format|
          format.js { render :error }
        end
      end
    end
  end

  def current_component
    return commentable.component if commentable.respond_to?(:component)
    return commentable.participatory_space if commentable.respond_to?(:participatory_space)
    return commentable if Decidim.participatory_space_manifests.find { |manifest| manifest.model_class_name == commentable.class.name }
  end
end
