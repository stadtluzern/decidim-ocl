# frozen_string_literal: true

source 'https://rubygems.org'

DECIDIM_VERSION = '0.29.3'

ruby RUBY_VERSION

gem 'execjs' # , '2.7.0'

gem 'decidim', DECIDIM_VERSION
gem 'decidim-conferences', DECIDIM_VERSION
gem 'decidim-initiatives', DECIDIM_VERSION
gem 'decidim-proposals', DECIDIM_VERSION
gem 'decidim-templates', DECIDIM_VERSION

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
    ref: 'afd2111'
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
    ref: '9c632e0'
gem 'decidim-reporting_proposals',
    github: 'openpoke/decidim-module-reporting-proposals',
    branch: 'upgrade-29.4',
    ref: '0ca71f9'
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
gem 'bootsnap'                # , '~> 1.3'
gem 'byebug'                  # , '~> 11.0', platform: :mri
gem 'dalli'
gem 'deface'
gem 'delayed_cron_job'
gem 'delayed_job_active_record'
gem 'faker'                   # , '~> 1.9'
gem 'lograge'
gem 'prometheus_exporter'
gem 'pry-byebug'
gem 'pry-rails'
gem 'puma'
gem 'sentry-raven'
gem 'sprockets-rails'
gem 'uglifier'                # , '~> 4.1'

group :development, :test     do
  gem 'better_errors'
  gem 'decidim-dev', DECIDIM_VERSION
end

group :development do
  gem 'letter_opener_web'     # , '~> 1.3'
  gem 'listen'                # , '~> 3.1'
  gem 'ruby-lsp'
  gem 'web-console'           # , '~> 3.5'
end

group :production do
  gem 'bleib'
end

gem 'dotenv', '~> 3.1'
