# frozen_string_literal: true

# Override
# --------
# Why it happens:
# When Decidim::ParticipatorySpaceContext#layout is called from an Initiative,
# it receives a Decidim::ResourceManifest
# instead of a Decidim::ParticipatorySpaceManifest
#
# How we fix it:
# We return the right manifest instead from Decidim::ParticipatorySpaceManifest#current_participatory_space_manifest

Decidim::ParticipatorySpaceContext.module_eval do
  private

  def current_participatory_space_manifest
    manifest = current_participatory_space&.manifest

    if manifest.instance_of?(Decidim::ResourceManifest) && manifest.name == 'initiative'
      return Decidim.find_participatory_space_manifest(:initiatives)
    end

    return manifest if current_participatory_space

    manifest = Decidim.find_participatory_space_manifest(
      self.class.name.demodulize.underscore.gsub('_controller', '')
    )

    raise NotImplementedError unless manifest

    manifest
  end
end
