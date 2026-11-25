# frozen_string_literal: true

Decidim.register_assets_path File.expand_path('app/packs', Rails.application.root)
Decidim.register_assets_path File.expand_path('app/packs/fonts', Rails.application.root)

# Hosts of the S3 storage (OCP4_S3_ENDPOINT) must be allowed by the CSP.
s3_host = URI(ENV.fetch('OCP4_S3_ENDPOINT', '')).host

Decidim.configure do |config| # rubocop:disable Metrics/BlockLength
  # ponytail: the 0.29 default list is kept; Decidim core defaults to a much longer list.
  config.available_locales = Decidim::Env.new('DECIDIM_AVAILABLE_LOCALES',
                                              'ca,cs,de,en,es,eu,fi,fr,it,ja,nl,pl,pt,ro').to_array

  # Map and Geocoder configuration (swisstopo)
  # See Decidim docs at https://docs.decidim.org/en/develop/services/maps
  config.maps = {
    provider: :swisstopo,
    dynamic: {
      provider: :swisstopo,
      default_center: {
        lat: 47.052,
        lng: 8.309
      },
      map_limits: {
        lat_min: 47.0,
        lat_max: 47.136,
        lng_min: 8.24,
        lng_max: 8.42
      },
      layers: {
        '0': {
          name: ->(*_args) { I18n.t('decidim_ocl.maps.swisstopo.basic') },
          layer: 'ch.swisstopo.pixelkarte-farbe'
        },
        '1': {
          name: ->(*_args) { I18n.t('decidim_ocl.maps.swisstopo.satellite') },
          layer: 'ch.swisstopo.swissimage'
        }
      },
      attribution: ->(*_args) { I18n.t('decidim_ocl.maps.swisstopo.attribution') }
    },
    static: false,
    geocoding: {
      provider: :osm,
      timeout: 5,
      units: :km
    },
    autocomplete: {
      provider: :osm,
      url: 'https://photon.komoot.io/api?lat=47.052&lon=8.309&bbox=8.18,47.016,8.373,47.095',
      address_format: [
        'name',
        %w[street housenumber],
        %w[postcode city]
      ]
    }
  }

  config.content_security_policies_extra = {
    'connect-src' => ['photon.komoot.io', s3_host].compact,
    'img-src' => ['*.geo.admin.ch', s3_host].compact,
    'media-src' => [s3_host].compact,
    'default-src' => [s3_host].compact
  }

  # OIDC (Mein Konto) provider; the other providers are read by Decidim core from OMNIAUTH_* ENV.
  config.omniauth_providers = config.omniauth_providers.merge(
    oidc: {
      enabled: Decidim::Env.new('MEIN_KONTO_ISSUER').present?,
      issuer: ENV.fetch('MEIN_KONTO_ISSUER', nil),
      client_id: ENV.fetch('MEIN_KONTO_CLIENT_ID', nil),
      client_secret: ENV.fetch('MEIN_KONTO_CLIENT_SECRET', nil),
      redirect_url: ENV.fetch('MEIN_KONTO_REDIRECT_URL', nil)
    }
  )

  # SMS gateway configuration
  config.sms_gateway_service = 'DecidimOCL::Verifications::Sms::AspsmsGateway'

  # Machine Translation Configuration
  config.enable_machine_translations = true
  config.machine_translation_delay = 0.seconds
  config.machine_translation_service = 'DecidimOCL::DeeplTranslator'

  # Don't require changing passwords every 90 days, as this leads to worse security according to OWASP
  config.admin_password_expiration_days = Decidim::Env.new('DECIDIM_ADMIN_PASSWORD_EXPIRATION_DAYS', 0).to_i

  # Denied passwords: 0.29 ENV name kept; Decidim core reads DECIDIM_DENIED_PASSWORDS
  if Decidim::Env.new('DECIDIM_PASSWORD_BLACKLIST').present?
    config.denied_passwords = Decidim::Env.new('DECIDIM_PASSWORD_BLACKLIST').to_array(separator: ', ')
  end

  # Disable the PWA functionality including the "add to home screen" feature for now
  config.service_worker_enabled = false
end

if Decidim.module_installed? :meetings
  Decidim::Meetings.configure do |config|
    if Decidim::Env.new('MEETINGS_EMBEDDABLE_SERVICES').present?
      config.embeddable_services = Decidim::Env.new('MEETINGS_EMBEDDABLE_SERVICES').to_array(separator: ' ')
    end
  end
end

if Decidim.module_installed? :initiatives
  Decidim::Initiatives.configure do |config|
    config.default_components = Decidim::Env.new('INITIATIVES_DEFAULT_COMPONENTS', 'pages, meetings').to_array
  end
end

Rails.application.config.i18n.available_locales = Decidim.available_locales
Rails.application.config.i18n.default_locale = Decidim.default_locale
