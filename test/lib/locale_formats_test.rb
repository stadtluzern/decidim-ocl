# frozen_string_literal: true

require 'test_helper'

# Every date/time format Decidim defines in English must resolve in German (our default locale, so there is no
# fallback): I18n.l with a missing format raises and takes whole pages down. 0.31.9 added
# time_of_day_with_time_zone without a German translation, which broke the home pages on DEV (#228).
class LocaleFormatsTest < ActiveSupport::TestCase
  decidim_en = Gem.loaded_specs.values.select { _1.name.start_with?('decidim') }
                  .map { File.join(_1.full_gem_path, 'config/locales/en.yml') }.select { File.exist?(_1) }

  { date: Date.new(2026, 11, 27), time: Time.utc(2026, 11, 27, 18, 30) }.each do |type, value|
    keys = decidim_en.flat_map { (YAML.load_file(_1, aliases: true).dig('en', type.to_s, 'formats') || {}).to_a }
    keys.each do |key, format|
      next unless format.is_a?(String)

      test "de #{type}.formats.#{key}" do
        assert_match(/\d|[[:alpha:]]/, I18n.l(value, format: key.to_sym, locale: :de))
      end
    end
  end
end
