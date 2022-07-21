# frozen_string_literal: true

Decidim::Map::Provider::Autocomplete::Osm::Builder.class_eval do
  def initialize(template, options)
    @template = template
    @options = options
    if map_config.present?
      @options[:url] = autocomplete_url(@options[:url])
    end
  end

  private

  def organization
    @organization ||= @template.current_organization
  end

  def map_config
    @map_config ||= organization&.map_config&.with_indifferent_access
  end

  def autocomplete_url(url)
    binding.pry
    # TODO handle URLs with query params which are not ordered exactly this way
    regex = /\?lat=([0-9.]*)&lon=([0-9.]*)&bbox=([0-9.]*),([0-9.]*),([0-9.]*),([0-9.]*)/
    regex.match url
    lat = map_config.dig(:default_center, :lat) || Regexp.last_match(1)
    lng = map_config.dig(:default_center, :lng) || Regexp.last_match(2)
    lng_min = map_config.dig(:map_limits, :lng_min) || Regexp.last_match(3)
    lat_min = map_config.dig(:map_limits, :lat_min) || Regexp.last_match(4)
    lng_max = map_config.dig(:map_limits, :lng_max) || Regexp.last_match(5)
    lat_max = map_config.dig(:map_limits, :lat_max) || Regexp.last_match(6)

    url.gsub(regex, "?lat=#{lat}&lon=#{lng}&bbox=#{lng_min},#{lat_min},#{lng_max},#{lat_max}")
  end

  def replace_if_set(string, regex, value)
    return string unless value
    string.gsub(regex, value)
  end
end