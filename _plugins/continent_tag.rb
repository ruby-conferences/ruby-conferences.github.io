require "countries"

module Jekyll
  class ContinentTag < Liquid::Block
    def render(context)
      country_code = super
      country = nil

      return "online" if country_code == "Online"

      country = ISO3166::Country.new("US") if ISO3166::Country.new("US").subdivisions.keys.include?(country_code)
      country = ISO3166::Country.new("GB") if country_code == "UK"
      country = ISO3166::Country.new("GB") if country_code == "Scotland"
      country = ISO3166::Country.find_country_by_iso_short_name(country_code) if country.nil?
      country = ISO3166::Country.find_country_by_unofficial_names(country_code) if country.nil?

      if country.nil?
        raise "Country not found: #{country_code}"
      end

      country.continent.gsub(/\s+/, "-").downcase
    end
  end
end

Liquid::Template.register_tag("continent", Jekyll::ContinentTag)
