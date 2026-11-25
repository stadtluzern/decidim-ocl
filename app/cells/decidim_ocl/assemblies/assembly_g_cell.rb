# frozen_string_literal: true

#  Decidim Luzern Override
#
#  Created at: 2026-08-05
#  Author: Carlo Beltrame
#
#  Original:
#    Module: decidim-assemblies
#    File: app/cells/decidim/assemblies/assembly_g_cell.rb
#
#  Why?:
#    Assemblies (labelled "Organisationen" here) without a hero image render
#    the generic Decidim placeholder icon. We want our own default image
#    instead. Re-implementation of the pre-redesign override.
#
#    Refs decidim-swiss/decidim.swiss#224, stadtluzern/decidim-ocl#63

module DecidimOCL
  module Assemblies
    # This cell renders the Grid (:g) assembly card for a given Assembly
    module AssemblyGCell
      private

      def resource_image_url
        super.presence || asset_pack_path('media/images/organization-default-image.png')
      end
    end
  end
end
