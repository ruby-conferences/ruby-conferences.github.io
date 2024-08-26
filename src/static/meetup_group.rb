require "ostruct"
require "tzinfo"
require "countries"

require_relative "./meetup"
require_relative "../static"
require_relative "../meetup_client"
require_relative "../queries/events_query"

class MeetupGroup < FrozenRecord::Base
  scope :meetupdotcom, -> { where(service: "meetupdotcom" ) }
  scope :luma, -> { where(service: "luma" ) }

  def upcoming_events
    @upcoming_events ||= begin
      result = MeetupClient::Client.query(EventsQuery, variables: { groupId: id })

      events = Array(result.original_hash.dig("data", "groupByUrlname", "unifiedEvents", "edges"))
      events = events.map { |event| OpenStruct.new(event["node"]) }

      if filter.present?
        events = events.select { |event| event.title.include?(filter) }
      end

      if exclude.present?
        events = events.reject { |event| event.title.include?(exclude) }
      end

      events
    end
  end

  def new_events
    upcoming = upcoming_events || []
    upcoming_ids = upcoming.map(&:id)

    new_event_ids = upcoming_ids - existing_event_ids

    new_event_ids
      .map { |new_id| upcoming.find { |upcoming| new_id == upcoming.id } }
      .sort_by(&:dateTime)
      .select { |event| Date.parse(event.dateTime).between?(Date.today - 1, Date.today + 90) }
  end

  def existing_events
    Meetup.all.select { |meetup| meetup.url.include?(id) }
  end

  def existing_event_ids
    existing_events.map(&:service_id)
  end

  def openstruct_to_file_entry(event)
    timezone = TZInfo::Timezone.get(event.timezone).now.strftime("%Z")

    MeetupsFileEntry.new(
      name: event_title(event),
      location: event_to_location(event),
      date: Date.parse(event.dateTime).iso8601,
      start_time: [Time.parse(event.dateTime).strftime("%H:%M:%S"), timezone].join(" "),
      end_time: [Time.parse(event.endTime).strftime("%H:%M:%S"), timezone].join(" "),
      url: event.eventUrl,
      group: self,
    )
  end

  private

    def event_title(event)
      title = event.title.gsub(name, "").squeeze(" ").gsub(remove || "", "").strip

      duplicate_names = upcoming_events.map(&:title).tally.select { |key, value| value >= 2 }

      if duplicate_names.any?
        title += " #{Date.parse(event.dateTime).strftime("%B %Y")}" if duplicate_names.keys.include?(event.title)
      end

      title = "Meetup #{Date.parse(event.dateTime).strftime("%B %Y")}" if title.blank?

      "#{name} - #{title}".gsub(/^-+|-+$/, "").gsub("- -", "-").gsub("- :", "-").squeeze(" ").strip
    end

    def event_to_location(event)
      city = event.dig("venue", "city") || event.dig("group", "city")
      state = event.dig("venue", "state") || event.dig("group", "state")
      country_raw = event.dig("venue", "country") || event.dig("group", "country")

      country = ISO3166::Country.new(country_raw)

      if event.isOnline
        "Online"
      elsif country.alpha2 == "US"
        "#{city}, #{state.upcase}"
      elsif country.alpha2 == "UK"
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
