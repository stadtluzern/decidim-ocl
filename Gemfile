# frozen_string_literal: true

source 'https://rubygems.org'

DECIDIM_VERSION = '= 0.24.0'

ruby RUBY_VERSION

gem 'decidim', DECIDIM_VERSION
gem 'decidim-proposals', DECIDIM_VERSION
# gem 'decidim-consultations', DECIDIM_VERSION
gem 'decidim-conferences', DECIDIM_VERSION
gem 'decidim-decidim_awesome', '~> 0.7.0'
# gem 'decidim-initiatives', DECIDIM_VERSION
gem 'decidim-jitsi_meetings',
    git: 'https://github.com/Kagemaru/decidim-module-jitsi-meetings.git',
    tag: '0.24.0'
gem 'decidim-navbar_links',
    git: 'https://github.com/puzzle/decidim-module-navbar_links',
    tag: 'v0.24.0'
gem 'decidim-navigation_maps',
    git: 'https://github.com/Platoniq/decidim-module-navigation_maps'
gem 'decidim-term_customizer',
    git: 'https://github.com/mainio/decidim-module-term_customizer'

gem 'bootsnap', '~> 1.3'
gem 'dalli'
gem 'delayed_job_active_record'
gem 'faker', '~> 1.9'
gem 'prometheus_exporter'
gem 'pry-rails'
gem 'puma'
gem 'uglifier', '~> 4.1'

group :development, :test do
  gem 'better_errors'
  gem 'byebug', '~> 11.0', platform: :mri
  gem 'pry-byebug'

  gem 'decidim-dev', DECIDIM_VERSION
end

group :development do
  gem 'letter_opener_web', '~> 1.3'
  gem 'listen', '~> 3.1'
  gem 'spring', '~> 2.0'
  gem 'spring-watcher-listen', '~> 2.0'
  gem 'web-console', '~> 3.5'
end

group :production do
  gem 'bleib'
end
