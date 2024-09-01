require "countries"

module Jekyll
  class ContinentTag < Liquid::Block
    def render(context)
      country_code = super

      return "online" if country_code == "Online"

      country = nil

      if country.nil?
        case country_code
        when "UK"
          country = ISO3166::Country.new("GB")
        when "Taiwan"
          country = ISO3166::Country.new("TW")
        when *ISO3166::Country.new("US").subdivisions.keys
          country = ISO3166::Country.new("US")
        end
      end

      if country.nil?
        country = ISO3166::Country.find_country_by_iso_short_name(country_code)
      end

      if country.nil?
        raise "Country not found: #{country_code}"
      end

      country.continent.gsub(/\s+/, "-").downcase
    end
  end
end

Liquid::Template.register_tag("continent", Jekyll::ContinentTag)
