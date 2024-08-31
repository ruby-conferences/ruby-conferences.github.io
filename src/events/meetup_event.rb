require "countries"

require_relative "./abstract_event"

class MeetupEvent < AbstractEvent
  def event_name
    object.title
  end

  def event_start_time
    DateTime.parse(object.dateTime)
  end

  def event_end_time
    DateTime.parse(object.endTime)
  end

  def event_url
    object.eventUrl
  end

  def event_location
    city = object.dig("venue", "city") || object.dig("group", "city")
    state = object.dig("venue", "state") || object.dig("group", "state")
    country_raw = object.dig("venue", "country") || object.dig("group", "country")

    country = ISO3166::Country.new(country_raw)

    if object.isOnline
      "Online"
    elsif country.alpha2 == "US"
      "#{city}, #{state.upcase}"
    elsif country.alpha2 == "GB"
      "#{city}, UK"
    elsif country.alpha2 == "TW"
      "#{city}, Taiwan"
    elsif country.alpha2 == "DK"
      "#{city == "1606" ? "Copenhagen" : city}, #{country&.iso_short_name}"
    elsif country
      "#{city}, #{country&.iso_short_name}"
    elsif city
      "#{city}, #{state}, #{country_raw.upcase}"
    else
      "Unknown"
    end
  end
end
