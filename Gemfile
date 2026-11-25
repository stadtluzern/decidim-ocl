# frozen_string_literal: true

source 'https://rubygems.org'

DECIDIM_VERSION = '0.31.8'

ruby RUBY_VERSION

# Decidim
gem 'decidim',
    github: 'openpoke/decidim',
    branch: '0.31-backports',
    ref: '2f36d585cfd452c38f4c7fa7eaa53af77ffe9c09'

# Internal Modules
# gem 'decidim-conferences', DECIDIM_VERSION
# gem 'decidim-initiatives', DECIDIM_VERSION
# gem 'decidim-proposals', DECIDIM_VERSION
# gem 'decidim-templates', DECIDIM_VERSION

gem 'decidim-collaborative_texts',
    github: 'openpoke/decidim',
    branch: '0.31-backports',
    ref: '2f36d585cfd452c38f4c7fa7eaa53af77ffe9c09',
    glob: 'decidim-collaborative_texts/*.gemspec'
gem 'decidim-conferences',
    github: 'openpoke/decidim',
    branch: '0.31-backports',
    ref: '2f36d585cfd452c38f4c7fa7eaa53af77ffe9c09',
    glob: 'decidim-conferences/*.gemspec'
gem 'decidim-elections',
    github: 'openpoke/decidim',
    branch: '0.31-backports',
    ref: '2f36d585cfd452c38f4c7fa7eaa53af77ffe9c09',
    glob: 'decidim-elections/*.gemspec'
gem 'decidim-initiatives',
    github: 'openpoke/decidim',
    branch: '0.31-backports',
    ref: '2f36d585cfd452c38f4c7fa7eaa53af77ffe9c09',
    glob: 'decidim-initiatives/*.gemspec'
gem 'decidim-proposals',
    github: 'openpoke/decidim',
    branch: '0.31-backports',
    ref: '2f36d585cfd452c38f4c7fa7eaa53af77ffe9c09',
    glob: 'decidim-proposals/*.gemspec'
gem 'decidim-templates',
    github: 'openpoke/decidim',
    branch: '0.31-backports',
    ref: '2f36d585cfd452c38f4c7fa7eaa53af77ffe9c09',
    glob: 'decidim-templates/*.gemspec'

# HACK: Using patched version of deface, to fix JS overrides
gem 'deface',
    github: 'froger/deface',
    branch: 'fix/js-overrides'

# External Modules
gem 'decidim-antivirus',
    github: 'puzzle/decidim-module-antivirus',
    branch: 'main',
    ref: '76a22d1'
gem 'decidim-decidim_awesome',
    github: 'decidim-ice/decidim-module-decidim_awesome',
    branch: 'release/0.31-stable',
    ref: '7470edb'
gem 'decidim-guest_meeting_registration',
    github: 'OpenSourcePolitics/guest-meeting-registration',
    branch: 'bump/0.31',
    ref: 'f0c5e2c'
gem 'decidim-navigation_maps',
    github: 'Platoniq/decidim-module-navigation_maps',
    branch: 'release/0.31-stable',
    ref: 'd207f53'
gem 'decidim-participatory_documents',
    github: 'openpoke/decidim-module-participatory-documents',
    branch: 'upgrade-0.31',
    ref: '5d8bde9'
gem 'decidim-reporting_proposals',
    github: 'openpoke/decidim-module-reporting-proposals',
    branch: 'main',
    ref: '1b77463'
gem 'decidim-survey_multiple_answers',
    github: 'OpenSourcePolitics/decidim-module-survey_multiple_answers',
    branch: 'bump/0.31',
    ref: '95eba87'
gem 'decidim-term_customizer',
    github: 'openpoke/decidim-module-term_customizer',
    branch: 'main',
    ref: '8cd8baf'

# TODO: These are not updated yet :(
# gem 'decidim-navbar_links', github: 'puzzle/decidim-module-navbar_links', tag: "v#{DECIDIM_VERSION}"
# gem 'decidim-url_aliases', github: 'OpenSourcePolitics/decidim-urlaliases'

gem 'activerecord-nulldb-adapter', github: 'puzzle/nulldb'
gem 'aws-sdk-s3', require: false
gem 'binding_of_caller'
gem 'bootsnap'
gem 'byebug'
gem 'connection_pool', '< 3.0.0' # rails 7.2 is not compatible with 3.0
gem 'dalli'
gem 'deepl-rb', require: 'deepl'
gem 'delayed_job_active_record'
gem 'execjs'
gem 'faker'
gem 'jwt', '< 3.2.0' # https://github.com/decidim/decidim/issues/16824
gem 'lograge'
gem 'omniauth_openid_connect'
gem 'prometheus_exporter'
gem 'pry-byebug'
gem 'pry-rails'
gem 'puma'
gem 'sentry-delayed_job'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sprockets-rails'
gem 'uglifier'
gem 'wicked_pdf'

group :development, :test do
  gem 'better_errors'
  gem 'decidim-dev', DECIDIM_VERSION
end

group :development do
  gem 'dotenv'
  gem 'letter_opener_web'
  gem 'listen'
  gem 'ruby-lsp'
  gem 'web-console'
end

group :production do
  gem 'bleib'
end

# Needs to be loaded after all other delayed_job gems
gem 'delayed_cron_job'
