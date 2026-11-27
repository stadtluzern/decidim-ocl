# frozen_string_literal: true

Decidim::Assemblies::Admin::AssembliesController.class_eval do
  # Only list assemblies the user may see. The JS branch (child assemblies of one parent, unpaginated) is
  # upstream's since 0.31.9 ("Show all child assemblies in admin list", decidim/decidim#18002).
  def filtered_collection
    valid_ids =
      query
      .result
      .select { |a| allowed_to? :list, :assembly, assembly: a }
      .map(&:id)

    assemblies = query.result.where(id: valid_ids)
    return assemblies if request.format.js? && ransack_params[:parent_id_eq].present?

    paginate(assemblies)
  end
end
