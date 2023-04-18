# frozen_string_literal: true

source 'https://rubygems.org'

DECIDIM_VERSION = '0.26.5'

ruby RUBY_VERSION

gem 'execjs' # , '2.7.0'

gem 'decidim', DECIDIM_VERSION
gem 'decidim-conferences', DECIDIM_VERSION
gem 'decidim-initiatives', DECIDIM_VERSION
gem 'decidim-proposals', DECIDIM_VERSION
gem 'decidim-templates', DECIDIM_VERSION

gem 'decidim-antivirus', github: 'puzzle/decidim-module-antivirus'
gem 'decidim-decidim_awesome', github: 'Platoniq/decidim-module-decidim_awesome'
gem 'decidim-jitsi_meetings', github: 'puzzle/decidim-module-jitsi-meetings', branch: DECIDIM_VERSION, ref: '6d32dd1'
gem 'decidim-navigation_maps', '~> 1.3.0'
gem 'decidim-question_captcha', github: 'Kagemaru/decidim-module-question_captcha', ref: 'v0.26.5'
gem 'decidim-reporting_proposals', git: "https://github.com/openpoke/decidim-module-reporting-proposals"
gem 'decidim-term_customizer', github: 'mainio/decidim-module-term_customizer', ref: 'release/0.26-stable'

# TODO: These are not updated yet :(
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
