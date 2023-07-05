# frozen_string_literal: true

source 'https://rubygems.org'

DECIDIM_VERSION = '0.27.3'

ruby RUBY_VERSION

gem 'execjs' # , '2.7.0'

gem 'decidim', DECIDIM_VERSION
gem 'decidim-conferences', DECIDIM_VERSION
gem 'decidim-initiatives', DECIDIM_VERSION
gem 'decidim-proposals', DECIDIM_VERSION
gem 'decidim-templates', DECIDIM_VERSION

gem 'decidim-antivirus', github: 'mainio/decidim-module-antivirus'
gem 'decidim-decidim_awesome', github: 'decidim-ice/decidim-module-decidim_awesome'
gem 'decidim-jitsi_meetings', github: 'puzzle/decidim-module-jitsi-meetings', branch: DECIDIM_VERSION
gem 'decidim-question_captcha', github: 'OpenSourcePolitics/decidim-module-question_captcha', branch: 'release/0.27-stable'
gem 'decidim-reporting_proposals', github: 'openpoke/decidim-module-reporting-proposals', branch: 'upgrade-0.27'
gem 'decidim-term_customizer', github: 'mainio/decidim-module-term_customizer', branch: 'master'

# TODO: These are not updated yet :(
# gem 'decidim-navigation_maps', '~> 1.3.0'
# gem 'decidim-navbar_links', github: 'puzzle/decidim-module-navbar_links', tag: "v#{DECIDIM_VERSION}"
# gem 'decidim-url_aliases', github: 'OpenSourcePolitics/decidim-urlaliases'

gem 'acts_as_textcaptcha', '~> 4.5.1'
gem 'aws-sdk-s3', require: false
gem 'binding_of_caller'
gem 'bootsnap'                # , '~> 1.3'
gem 'byebug'                  # , '~> 11.0', platform: :mri
gem 'dalli'
gem 'delayed_job_active_record'
gem 'faker'                   # , '~> 1.9'
gem 'lograge'
gem 'prometheus_exporter'
gem 'pry-byebug'
gem 'pry-rails'
gem 'puma'
gem 'sentry-raven'
gem 'uglifier'                # , '~> 4.1'
gem 'webpacker'               # , "~> 6.0.rc.6"

group :development, :test     do
  gem 'better_errors'
  gem 'decidim-dev', DECIDIM_VERSION
end

group :development do
  gem 'letter_opener_web'     # , '~> 1.3'
  gem 'listen'                # , '~> 3.1'
  gem 'solargraph'
  gem 'spring'                # , '~> 2.0'
  gem 'spring-watcher-listen' # , '~> 2.0'
  gem 'web-console'           # , '~> 3.5'
end

group :production do
  gem 'bleib'
end
