# frozen_string_literal: true

# DeepL Translation service configuration
DeepL.configure do |config|
  config.auth_key = Rails.application.secrets.translator[:secret_key]
  config.host = Rails.application.secrets.translator[:endpoint_url]
end

# Need to reset cached values inside the deepl client library because we
# may change the host from api.deepl.com to api-free.deepl.com
DeepL.instance_variable_set(:@api, nil)
