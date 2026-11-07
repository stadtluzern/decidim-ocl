# frozen_string_literal: true

# DeepL Translation service configuration
DeepL.configure do |config|
  config.auth_key = Decidim::Env.new('TRANSLATOR_SECRET_KEY', 'please-set-the-deepl-key-as-env-var').to_s
  config.host = Decidim::Env.new('TRANSLATOR_ENDPOINT_URL', 'https://api.deepl.com').to_s
end

# Need to reset cached values inside the deepl client library because we
# may change the host from api.deepl.com to api-free.deepl.com
DeepL.instance_variable_set(:@api, nil)
