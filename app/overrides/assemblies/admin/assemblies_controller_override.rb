# frozen_string_literal: true

Decidim::Assemblies::Admin::AssembliesController.class_eval do
  def filtered_collection
    valid_ids =
      query
      .result
      .select { |a| allowed_to? :list, :assembly, assembly: a }
      .map(&:id)

    assemblies = query.result.where(id: valid_ids)

    paginate(assemblies)
  end
end
