# frozen_string_literal: true

source 'https://rubygems.org'

DECIDIM_VERSION = '0.28.5'

ruby RUBY_VERSION

gem 'execjs' # , '2.7.0'

gem 'decidim', DECIDIM_VERSION
gem 'decidim-conferences', DECIDIM_VERSION
gem 'decidim-initiatives', DECIDIM_VERSION
gem 'decidim-proposals', DECIDIM_VERSION
gem 'decidim-templates', DECIDIM_VERSION

#gem 'decidim-anonymous_codes', github: 'openpoke/decidim-module-anonymous_codes' # deactivated because no compatible version for decidim 0.28 exists
gem 'decidim-antivirus', github: 'mainio/decidim-module-antivirus', branch: 'main'
gem 'decidim-decidim_awesome', github: 'decidim-ice/decidim-module-decidim_awesome', branch: 'release/0.28-stable'
gem 'decidim-participatory_documents', github: 'openpoke/decidim-module-participatory-documents', branch: 'upgrade-0.28'
#gem 'decidim-question_captcha', github: 'OpenSourcePolitics/decidim-module-question_captcha', branch: 'release/0.27-stable' # deactivated because no compatible version for decidim 0.28 exists
gem 'decidim-reporting_proposals', github: 'openpoke/decidim-module-reporting-proposals', branch: 'main'
#gem 'decidim-survey_multiple_answers', '~> 0.26.2' # deactivated because no compatible version for decidim 0.28 exists
#gem 'decidim-term_customizer', github: 'mainio/decidim-module-term_customizer', branch: 'release/0.27-stable' # deactivated because no compatible version for decidim 0.28 exists

gem 'decidim-navigation_maps', github: 'Platoniq/decidim-module-navigation_maps', branch: 'release/0.28-stable'
#gem 'decidim-guest_meeting_registration', github: 'alecslupu-pfa/guest-meeting-registration', branch: 'release/0.27-stable' # deactivated because no compatible version for decidim 0.28 exists

# TODO: These are not updated yet :(
# gem 'decidim-navbar_links', github: 'puzzle/decidim-module-navbar_links', tag: "v#{DECIDIM_VERSION}"
# gem 'decidim-url_aliases', github: 'OpenSourcePolitics/decidim-urlaliases'
gem 'activerecord-nulldb-adapter'
gem 'acts_as_textcaptcha'
gem 'aws-sdk-s3', require: false
gem 'binding_of_caller'
gem 'bootsnap'                # , '~> 1.3'
gem 'byebug'                  # , '~> 11.0', platform: :mri
gem 'dalli'
gem 'deface'
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
  gem 'solargraph'
  gem 'web-console'           # , '~> 3.5'
end

group :production do
  gem 'bleib'
end

gem 'dotenv', '~> 3.1'
