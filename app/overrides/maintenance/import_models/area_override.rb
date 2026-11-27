# frozen_string_literal: true

require 'decidim/maintenance' # only the taxonomy rake tasks load it; without it the app fails to boot

# Taxonomy import (decidim:taxonomies:make_plan, 0.31): `areas_with_type` names the area type node by its
# `plural`, but the filter items point to the area type `name`. Where they differ (dialogluzern:
# "Quartiere der Stadt Luzern" vs "Quartier der Stadt Luzern") the import creates a second type node with
# all areas under it, and the filters use the duplicates. Use the plural here too. Unfixed upstream
# (release/0.31-stable and develop, 2026-11-27); found in the DEV rehearsal (#228). Remove after the upgrade.
Decidim::Maintenance::ImportModels::Area.class_eval do
  def self.filter_item_for_space_manifest(participatory_space_manifests)
    locale = I18n.locale.to_s
    items = all_in_org.map do |area|
      area.area_type ? [area.area_type.plural[locale], area.name[locale]] : [area.name[locale]]
    end

    { participatory_space_manifests:, name: root_taxonomy_name, items:, components: [] }
  end
end
