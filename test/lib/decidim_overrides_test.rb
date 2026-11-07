# frozen_string_literal: true

require 'test_helper'
require 'digest'
require 'prism'

# Our app code that replaces or patches Decidim code, with MD5s of the Decidim code it depends on.
# A failure means that Decidim code changed, usually with a Decidim update: re-test our file, then
# update the MD5 (the failure shows the new value). Deface overrides: see deface_overrides_test.rb.
#
# Every app file replacing a Decidim file (same path), every app/overrides/**/*_override.rb and every
# module in PREPENDS/INCLUDES (config/initializers/decidim_ocl_customization.rb) needs an entry
# covering what it touches: the replaced file, or for Ruby code each Decidim method it (re)defines,
# its class, or the file defining it.
#
# our file => {
#   description: what our file changes and why (required),
#   tickets:     issue URLs where it's tracked, in this or another project's repo (optional),
#   targets: { the Decidim code it depends on, only this is checked (required):
#     files:   { 'path in a Decidim gem' => MD5 }, prefixed with the gem name if several gems have it
#              ('config/locales/en.yml' vs. 'decidim-core/config/locales/en.yml'),
#     classes: { 'Decidim::Class' => MD5 of the class body },
#     methods: { 'Decidim::Class#method' => MD5 of the method }
#   }
# }

# rubocop:disable Layout/LineLength -- MD5 table rows with long Decidim paths
DECIDIM_OVERRIDE_CHECKS = {
  # Ruby overrides whose target is gone from Decidim 0.31.8 carry nil: the test reports them until they are re-targeted or removed.
  'app/overrides/assemblies/admin/assemblies_controller_override.rb' => {
    description: 'Admin assemblies list: filtered_collection override (method lives in Decidim::Admin::Filterable)',
    targets: {
      classes: { 'Decidim::Assemblies::Admin::AssembliesController' => '36d79d9f157137feab81d941e8a0eac8' }
    }
  },
  'app/overrides/cells/decidim/translation_bar_cell_override.rb' => {
    description: 'Shows the translation banner only outside the organization default locale',
    targets: {
      methods: { 'Decidim::TranslationBarCell#renderable?' => '099e3c47938bde03a5635b7fadb41dcd' }
    }
  },
  'app/overrides/commands/decidim/create_follow_override.rb' => {
    description: 'Overrides follow creation',
    targets: {
      methods: { 'Decidim::CreateFollow#create_follow!' => 'a27aa741cc8082c31c2b588d19cb909b' }
    }
  },
  'app/overrides/controllers/concerns/decidim_ocl/participatory_space_context_override.rb' => {
    description: 'Returns the participatory space manifest for initiatives (ResourceManifest case)',
    targets: {
      methods: { 'Decidim::ParticipatorySpaceContext#current_participatory_space_manifest' => '1827daa0f2c207476e2b106ff58f5d36' }
    }
  },
  'app/overrides/controllers/decidim/participatory_documents/documents_controller_override.rb' => {
    description: 'Overrides PDF custom style for participatory documents',
    targets: {
      classes: { 'Decidim::ParticipatoryDocuments::DocumentsController' => '9d6777b9ac0147c26b8c74a8a1ff3154' }
    }
  },
  'app/overrides/forms/decidim/system/update_organization_form_override.rb' => {
    description: 'Adds the tenant_type and aspsms attributes to the system organization form',
    targets: {
      classes: { 'Decidim::System::UpdateOrganizationForm' => '2057b0e412c3b5cc1bca582b8ea2ed06' }
    }
  },
  'app/overrides/mailers/application_mailer_override.rb' => {
    description: 'Sets the mailer from address',
    targets: {
      methods: { 'Decidim::ApplicationMailer#set_from' => 'adbeafe13e864733c3252b1616a6a161' }
    }
  },
  'app/overrides/map/provider/autocomplete/osm_override.rb' => {
    description: 'Osm autocomplete builder with configurable map config and URL',
    targets: {
      classes: { 'Decidim::Map::Provider::Autocomplete::Osm::Builder' => 'a8b26eba533484f68f41d68fc0b3c180' }
    }
  },
  'app/overrides/meetings/directory/meetings_controller_override.rb' => {
    description: 'Directory meetings listing: past/upcoming filter and custom search',
    targets: {
      classes: { 'Decidim::Meetings::Directory::MeetingsController' => 'cc7f74c013792f5f6f559568fa37fb6f' }
    }
  },
  'app/overrides/meetings/meetings_controller_override.rb' => {
    description: 'Meetings listing: past/upcoming filter and custom search',
    targets: {
      classes: { 'Decidim::Meetings::MeetingsController' => 'e95c09012b71feae6859ab2d9def5860' }
    }
  },
  'app/commands/decidim_ocl/system/update_organization.rb' => {
    description: 'Saves the organization with the tenant_type and SMS settings',
    targets: {
      methods: { 'Decidim::System::UpdateOrganization#save_organization' => '527ae2ccb5d85c1659aa76f4845b4675' }
    }
  },
  'app/mailers/decidim_ocl/surveys/survey_confirmation_mailer.rb' => {
    description: 'Survey confirmation mail with responses file (checks the base mailer file, renamed in 0.31.8)',
    targets: {
      files: {
        'decidim-surveys/app/mailers/decidim/surveys/survey_confirmation_mailer.rb' => '26c16d0ac42c5396ed361319b25d0a47'
      }
    }
  },
  'app/cells/decidim_ocl/proposals/proposal_metadata_cell.rb' => {
    description: 'Proposal metadata state item',
    targets: {
      methods: { 'Decidim::Proposals::ProposalMetadataCell#state_item' => '8e37102a6ccde60b0c327676338dc8b4' }
    }
  },
  'app/cells/decidim_ocl/assemblies/assembly_g_cell.rb' => {
    description: 'Assembly card falls back to the organization default image',
    targets: {
      methods: {
        'Decidim::Assemblies::AssemblyGCell#resource_image_url' => '540cf26f96079b227d753b0f83419221'
      }
    }
  },
  'app/views/decidim/admin/scope_types/index.html.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/decidim/admin/scope_types/index.html.erb' => 'ab51f2c75e21229b34158f72f0644517' }
    }
  },
  'app/views/decidim/initiatives/admin/committee_requests/index.html.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/decidim/initiatives/admin/committee_requests/index.html.erb' => '73dff9c6fc17a3befd3d0d26cc888c25' }
    }
  },
  'app/views/decidim/initiatives/create_initiative/_share_committee_link.html.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/decidim/initiatives/create_initiative/_share_committee_link.html.erb' => '6a90f6511d2095b63bf5efad0eaffa00' }
    }
  },
  'app/views/decidim/initiatives/initiatives/_form.html.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/decidim/initiatives/initiatives/_form.html.erb' => 'd52fcbfa2a682b57fa4ab3be9aa7dc3a' }
    }
  },
  'app/views/decidim/initiatives/initiatives_mailer/_initiative_link.html.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/decidim/initiatives/initiatives_mailer/_initiative_link.html.erb' => 'de47dff7b873d61f8862cfe98c5e83d6' }
    }
  },
  'app/views/decidim/initiatives/initiatives_mailer/notify_creation.html.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/decidim/initiatives/initiatives_mailer/notify_creation.html.erb' => 'df0eeccf28b84fc55bcf93410308d38d' }
    }
  },
  'app/views/decidim/decidim_awesome/map_component/map/_api_ready.html.erb' => {
    description: 'Empty map API-ready partial replacing a decidim-awesome one (decidim-awesome bug workaround)',
    targets: {
      files: {
        'app/views/decidim/decidim_awesome/map_component/map/_api_ready.html.erb' => '0f17afd757ac83dc231cdef7cab31f5f'
      }
    }
  },
  'app/views/devise/mailer/confirmation_instructions.html.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/devise/mailer/confirmation_instructions.html.erb' => '17892d385f06877380f2f32cdd3f0635' }
    }
  },
  'app/views/devise/mailer/invitation_instructions.html.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/devise/mailer/invitation_instructions.html.erb' => 'b91d1abb95c177c7a1e589d3b219aed9' }
    }
  },
  'app/views/devise/mailer/invitation_instructions.text.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/devise/mailer/invitation_instructions.text.erb' => '9cead0ff427148d0b61717d471488116' }
    }
  },
  'app/views/devise/mailer/invite_admin.html.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/devise/mailer/invite_admin.html.erb' => '4b84f2d411ed8da3d31471e869161536' }
    }
  },
  'app/views/devise/mailer/invite_admin.text.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/devise/mailer/invite_admin.text.erb' => '3ae01561d9f2754604bb5fd39d32a50a' }
    }
  },
  'app/views/devise/mailer/invite_collaborator.html.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/devise/mailer/invite_collaborator.html.erb' => '4b84f2d411ed8da3d31471e869161536' }
    }
  },
  'app/views/devise/mailer/invite_collaborator.text.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/devise/mailer/invite_collaborator.text.erb' => '3ae01561d9f2754604bb5fd39d32a50a' }
    }
  },
  'app/views/devise/mailer/invite_private_user.html.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/devise/mailer/invite_private_user.html.erb' => 'f978eddb05fa55af2c33ce78c964a2bb' }
    }
  },
  'app/views/devise/mailer/invite_private_user.text.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/devise/mailer/invite_private_user.text.erb' => 'c8de91d2c1e9ddb69c2f8e3935aa41a5' }
    }
  },
  'app/views/devise/mailer/organization_admin_invitation_instructions.html.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/devise/mailer/organization_admin_invitation_instructions.html.erb' => '33afd7cdd7b4d78f7d76964cd6b2b2a2' }
    }
  },
  'app/views/devise/mailer/organization_admin_invitation_instructions.text.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/devise/mailer/organization_admin_invitation_instructions.text.erb' => '49615576f513b7632fb70a15d9458faa' }
    }
  },
  'app/views/devise/mailer/password_change.html.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/devise/mailer/password_change.html.erb' => '1c339299077b3764ca96bc8320d78175' }
    }
  },
  'app/views/devise/mailer/reset_password_instructions.html.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/devise/mailer/reset_password_instructions.html.erb' => '40e2a215f87b399286f9039be73af22c' }
    }
  },
  'app/views/devise/mailer/unlock_instructions.html.erb' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/views/devise/mailer/unlock_instructions.html.erb' => 'f3ff9db265717af4079a62180652ce93' }
    }
  },
  'app/packs/src/decidim/geocoding/provider/photon.js' => {
    description: 'App copy of a Decidim template, replaces the Decidim original',
    targets: {
      files: { 'app/packs/src/decidim/geocoding/provider/photon.js' => '7a32057a493be733d0224bcb30016ed0' }
    }
  }
}.freeze
# rubocop:enable Layout/LineLength

class DecidimOverridesTest < ActiveSupport::TestCase # rubocop:disable Metrics/ClassLength
  ENTRY_KEYS = %i[description tickets targets].freeze
  TARGET_KINDS = %i[files classes methods].freeze

  # Decidim files that exist to be replaced by the app; replacing them needs no entry
  EXTENSION_POINTS = %w[
    app/views/layouts/decidim/_head_extra.html.erb
    app/packs/src/decidim/decidim_application.js
    app/packs/stylesheets/decidim/decidim_application.scss
  ].freeze

  DECIDIM_GEM_DIRS = Gem.loaded_specs.values
                        .select { |spec| spec.name.start_with?('decidim') }
                        .to_h { |spec| [spec.name, spec.gem_dir] }

  def self.app_files(pattern)
    Rails.root.glob(pattern).map { |path| path.relative_path_from(Rails.root).to_s }
  end

  REPLACED = app_files('app/{views,cells,packs}/**/*.*').select do |path|
    DECIDIM_GEM_DIRS.values.any? { |dir| File.file?(File.join(dir, path)) }
  end - EXTENSION_POINTS
  RUBY_OVERRIDES = app_files('app/overrides/**/*_override.rb')
  # Our modules prepended/included into Decidim (config/initializers/decidim_ocl_customization.rb) => their bases
  MIXINS = (INCLUDES + PREPENDS).group_by(&:last).to_h do |mixin, pairs|
    [Pathname(Module.const_source_location(mixin.name).first).relative_path_from(Rails.root).to_s, pairs.map(&:first)]
  end

  (DECIDIM_OVERRIDE_CHECKS.keys | REPLACED | RUBY_OVERRIDES | MIXINS.keys).sort.each do |file|
    test file do
      checks = DECIDIM_OVERRIDE_CHECKS.fetch(file) { flunk "#{file} has no entry in DECIDIM_OVERRIDE_CHECKS" }
      assert_valid_entry(file, checks)
      targets = checks[:targets]
      assert_empty uncovered(file, targets),
                   "Touches Decidim code its DECIDIM_OVERRIDE_CHECKS entry doesn't list:#{context(file, checks)}"

      actual = targets.to_h { |kind, md5s| [kind, md5s.to_h { |name, _| [name, md5_of(kind, name)] }] }
      assert_empty actual.values.flat_map { |md5s| md5s.select { |_, md5| md5.nil? }.keys },
                   "No longer in Decidim, re-check:#{context(file, checks)}"
      assert_equal targets, actual, "Decidim code changed, re-test and update the MD5s:#{context(file, checks)}"
    end
  end

  private

  def assert_valid_entry(file, checks)
    assert checks[:description].present?, "#{file} has no description in DECIDIM_OVERRIDE_CHECKS"
    assert checks[:targets].present?, "#{file} has no targets in DECIDIM_OVERRIDE_CHECKS"
    assert_empty checks.keys - ENTRY_KEYS, "#{file}: unknown keys in its DECIDIM_OVERRIDE_CHECKS entry"
    assert_empty checks[:targets].keys - TARGET_KINDS, "#{file}: unknown keys in its DECIDIM_OVERRIDE_CHECKS targets"
  end

  def context(file, checks)
    "\n  File:    #{file}\n  What:    #{checks[:description]}\n  Tickets: #{checks.fetch(:tickets, ['-']).join(', ')}\n"
  end

  # Decidim code our file touches that its targets don't cover
  def uncovered(file, targets)
    return [file] - targets.fetch(:files, {}).keys.map { |key| without_gem(key) } if REPLACED.include?(file)
    return uncovered_by_ruby_override(file, targets) if RUBY_OVERRIDES.include?(file)
    return uncovered_by_mixin(file, targets) if MIXINS.key?(file)

    []
  end

  # Each method the override defines, unless the targets cover its whole class or the class's file
  def uncovered_by_ruby_override(file, targets)
    constant, methods = parse_override(file)
    class_file = Module.const_source_location(constant)&.first
    return [] if targets.fetch(:classes, {}).key?(constant)
    return [] if targets.fetch(:files, {}).keys.any? { |key| decidim_file(key) == class_file }

    methods.map { |method| "#{constant}##{method}" } - targets.fetch(:methods, {}).keys
  end

  # Each Decidim method the mixin overrides, unless the targets cover it, its base class or the file defining it
  def uncovered_by_mixin(file, targets)
    covered = targets.values.flat_map(&:keys) + targets.fetch(:files, {}).keys.map { |key| decidim_file(key) }
    mixin_overrides(file).reject { |override| override.intersect?(covered) }.map(&:first)
  end

  # ['Base#method', Decidim file defining it, 'Base'] for each Decidim method the mixin overrides
  def mixin_overrides(file)
    MIXINS[file].product(parse(file).grep(Prism::DefNode).map(&:name)).filter_map do |base, method|
      path = upstream_file(base, method)
      ["#{base.name}##{method}", path, base.name] if path
    end
  end

  # Decidim file defining the method our mixin overrides: the next Decidim definition up the
  # ancestors (prepend), or the base's own file when `included do` replaced the method there
  def upstream_file(base, method)
    upstream = base.instance_method(method)
    upstream = upstream.super_method until upstream.nil? || decidim_path?(upstream.source_location.first)
    upstream&.source_location&.first ||
      (Module.const_source_location(base.name).first if method_node(base.name, method.to_s))
  end

  def decidim_path?(path)
    DECIDIM_GEM_DIRS.values.any? { |dir| path.start_with?("#{dir}/") }
  end

  def parse(file)
    all_nodes(Prism.parse_file(Rails.root.join(file).to_s).value)
  end

  # The patched constant and the methods an override defines
  def parse_override(file)
    nodes = parse(file)
    eval_call = nodes.find { |node| node.is_a?(Prism::CallNode) && %i[class_eval module_eval].include?(node.name) }
    [eval_call.receiver.full_name, nodes.grep(Prism::DefNode).map { |node| node.name.to_s }]
  end

  def md5_of(kind, name)
    case kind
    when :files then (path = decidim_file(name)) && Digest::MD5.file(path).hexdigest
    when :classes then md5(class_node(name)&.slice)
    when :methods then md5(method_node(*name.split('#'))&.slice)
    end
  end

  def gem_name(key)
    first = key.split('/').first
    first if DECIDIM_GEM_DIRS.key?(first)
  end

  def without_gem(key)
    key.delete_prefix("#{gem_name(key)}/")
  end

  # Absolute path of a Decidim file, given as 'path' or 'gem/path'
  def decidim_file(key)
    dirs = gem_name(key) ? [DECIDIM_GEM_DIRS[gem_name(key)]] : DECIDIM_GEM_DIRS.values
    found = dirs.map { |dir| File.join(dir, without_gem(key)) }.select { |path| File.file?(path) }
    flunk "#{key} exists in several Decidim gems, prefix it with the gem name" if found.size > 1
    found.first
  end

  def class_node(constant)
    file = Module.const_source_location(constant)&.first
    return unless file

    all_nodes(Prism.parse_file(file).value).find do |node|
      [Prism::ClassNode, Prism::ModuleNode].include?(node.class) &&
        node.constant_path.full_name.split('::').last == constant.demodulize
    end
  rescue NameError
    nil
  end

  def method_node(constant, method)
    all_nodes(class_node(constant)).grep(Prism::DefNode).find { |node| node.name.to_s == method }
  end

  def md5(source)
    source && Digest::MD5.hexdigest(source)
  end

  def all_nodes(node)
    return [] unless node

    [node, *node.compact_child_nodes.flat_map { |child| all_nodes(child) }]
  end
end
