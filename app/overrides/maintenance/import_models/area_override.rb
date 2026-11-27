# frozen_string_literal: true

require 'decidim/maintenance' # only the taxonomy rake tasks load it; without it the app fails to boot

# Taxonomy import (decidim:taxonomies:make_plan, 0.31): `areas_with_type` names the area type node by its
# `plural`, but the filter items point to the area type `name`. Where they differ (dialogluzern:
# "Quartiere der Stadt Luzern" vs "Quartier der Stadt Luzern") the import creates a second type node with
# all areas under it, and the filters use the duplicates. Use the plural here too. Found in the DEV rehearsal
# (#228). Still unfixed in v0.31.9 and openpoke 567b232 (2026-11-27). Remove after the PROD taxonomy import
# (only make_plan uses it) or when the MD5 check in test/lib/decidim_overrides_test.rb reports an upstream change.
Decidim::Maintenance::ImportModels::Area.class_eval do
  def self.filter_item_for_space_manifest(participatory_space_manifests)
    locale = I18n.locale.to_s
    items = all_in_org.map do |area|
      area.area_type ? [area.area_type.plural[locale], area.name[locale]] : [area.name[locale]]
    end

    { participatory_space_manifests:, name: root_taxonomy_name, items:, components: [] }
  end
end
