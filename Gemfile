# frozen_string_literal: true

source 'https://rubygems.org'

DECIDIM_VERSION = '0.29.7'

ruby RUBY_VERSION

# Decidim
gem 'decidim',
    github: 'openpoke/decidim',
    branch: '0.29-backports',
    ref: '13fd72f1338dbf445239a934c4b62e1b7169f7f9'
# Internal Modules
# gem 'decidim-conferences', DECIDIM_VERSION
# gem 'decidim-initiatives', DECIDIM_VERSION
# gem 'decidim-proposals', DECIDIM_VERSION
# gem 'decidim-templates', DECIDIM_VERSION

gem 'decidim-conferences',
    github: 'openpoke/decidim',
    branch: '0.29-backports',
    ref: '13fd72f1338dbf445239a934c4b62e1b7169f7f9'
gem 'decidim-initiatives',
    github: 'openpoke/decidim',
    branch: '0.29-backports',
    ref: '13fd72f1338dbf445239a934c4b62e1b7169f7f9'
gem 'decidim-proposals',
    github: 'openpoke/decidim',
    branch: '0.29-backports',
    ref: '13fd72f1338dbf445239a934c4b62e1b7169f7f9'
gem 'decidim-templates',
    github: 'openpoke/decidim',
    branch: '0.29-backports',
    ref: '13fd72f1338dbf445239a934c4b62e1b7169f7f9'

# HACK: Using patched version of deface, to fix decidim-geo JS Errors
gem 'deface',
    github: 'froger/deface',
    branch: 'fix/js-overrides'

# External Modules
gem 'decidim-anonymous_codes',
    github: 'openpoke/decidim-module-anonymous_codes',
    branch: 'main',
    ref: '8323978'
gem 'decidim-antivirus',
    github: 'puzzle/decidim-module-antivirus',
    branch: 'master',
    ref: 'bc3cb4d'
gem 'decidim-decidim_awesome',
    github: 'decidim-ice/decidim-module-decidim_awesome',
    branch: 'release/0.29-stable',
    ref: 'a9f2077'
gem 'decidim-guest_meeting_registration',
    github: 'OpenSourcePolitics/guest-meeting-registration',
    branch: 'bump/module_to_0.29',
    ref: '19e3998'
gem 'decidim-navigation_maps',
    github: 'Platoniq/decidim-module-navigation_maps',
    branch: 'release/0.29-stable',
    ref: '349e4e3'
gem 'decidim-participatory_documents',
    github: 'openpoke/decidim-module-participatory-documents',
    branch: 'main',
    ref: '21501f8'
gem 'decidim-reporting_proposals',
    github: 'openpoke/decidim-module-reporting-proposals',
    branch: 'main',
    ref: 'cbbb29c'
gem 'decidim-survey_multiple_answers',
    github: 'OpenSourcePolitics/decidim-module-survey_multiple_answers',
    branch: 'bump/0.29',
    ref: '971ad38'
gem 'decidim-term_customizer',
    github: 'OpenSourcePolitics/decidim-module-term_customizer',
    branch: 'master',
    ref: '3da4973'

# TODO: These are not updated yet :(
# gem 'decidim-navbar_links', github: 'puzzle/decidim-module-navbar_links', tag: "v#{DECIDIM_VERSION}"
# gem 'decidim-url_aliases', github: 'OpenSourcePolitics/decidim-urlaliases'

gem 'activerecord-nulldb-adapter', github: 'puzzle/nulldb'
gem 'aws-sdk-s3', require: false
gem 'binding_of_caller'
gem 'bootsnap'
gem 'byebug'
gem 'dalli'
gem 'deepl-rb', require: 'deepl'
gem 'delayed_job_active_record'
gem 'execjs'
gem 'faker'
gem 'lograge'
gem 'prometheus_exporter'
gem 'pry-byebug'
gem 'pry-rails'
gem 'puma'
gem 'sentry-delayed_job'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sprockets-rails'
gem 'uglifier'

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
