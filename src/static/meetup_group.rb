require "ostruct"
require "tzinfo"
require "countries"
require "icalendar"

require_relative "./meetup"
require_relative "../static"
require_relative "../meetup_client"
require_relative "../queries/events_query"

class MeetupGroup < FrozenRecord::Base
  scope :meetupdotcom, -> { where(service: "meetupdotcom" ) }
  scope :luma, -> { where(service: "luma" ) }

  def upcoming_events_meetup
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

  def upcoming_events_luma
    ical_content = Net::HTTP.get(URI(ical_url))
    calendars = Icalendar::Calendar.parse(ical_content)

    events = calendars.first.events

    if filter.present?
      events = events.select { |event| event.summary.include?(filter) }
    end

    if exclude.present?
      events = events.reject { |event| event.summary.include?(exclude) }
    end

    events
  end

  def upcoming_events
    if service == "meetupdotcom"
      upcoming_events_meetup
    else
      upcoming_events_luma
    end
  end

  def new_events_meetup
    upcoming = upcoming_events_meetup || []
    upcoming_ids = upcoming.map(&:id)

    new_event_ids = upcoming_ids - existing_event_ids

    new_event_ids
      .map { |new_id| upcoming.find { |upcoming| new_id == upcoming.id } }
      .sort_by(&:dateTime)
      .select { |event| Date.parse(event.dateTime).between?(Date.today - 1, Date.today + 90) }
  end

  def new_events_luma
    upcoming = upcoming_events_luma || []
    upcoming_ids = upcoming.map { |event| event.description.scan(/https:\/\/lu.ma\/(.+)/).first.first }

    new_event_ids = upcoming_ids - existing_event_ids

    new_event_ids
      .map { |new_id| upcoming.find { |upcoming| new_id == upcoming.description.scan(/https:\/\/lu.ma\/(.+)/).first.first } }
      .sort_by(&:dtstart)
      .select { |event| event.dtstart.between?(Date.today - 1, Date.today + 90) }
  end

  def new_events
    if service == "meetupdotcom"
      new_events_meetup
    else
      new_events_luma
    end
  end

  def existing_events
    if service == "meetupdotcom"
      Meetup.all.select { |meetup| meetup.url.include?(id) }
    else
      Meetup.all.select { |meetup| meetup.name.include?(name) }
    end
  end

  def existing_event_ids
    existing_events.map(&:service_id)
  end

  def tz
    return nil if timezone.nil?

    @tz ||= TZInfo::Timezone.get(timezone)
  end

  def openstruct_to_file_entry(event)
    if service == "meetupdotcom"
      openstruct_to_file_entry_meetup(event)
    else
      openstruct_to_file_entry_luma(event)
    end
  end

  def openstruct_to_file_entry_meetup(event)
    timezone = tz || TZInfo::Timezone.get(event.timezone)

    MeetupsFileEntry.new(
      name: event_title_meetup(event),
      location: event_to_location(event),
      date: Date.parse(event.dateTime).iso8601,
      start_time: [Time.parse(event.dateTime).strftime("%H:%M:%S"), timezone.now.strftime("%Z")].join(" "),
      end_time: [Time.parse(event.endTime).strftime("%H:%M:%S"), timezone.now.strftime("%Z")].join(" "),
      url: event.eventUrl,
      group: self,
    )
  end

  def openstruct_to_file_entry_luma(event)
    location = event.location.to_s

    if location.start_with?("https://")
      location = "Online"
    else
      location_parts = location.split(",").map(&:strip)
      location_parts.delete("USA")

      if (match = location_parts.last.match(/([A-Z]{2}) (\d{4,5})/))
        location_parts.delete(location_parts.last)
        location_parts << match[1]
      end

      location = location_parts.last(2).join(", ").strip
    end

    MeetupsFileEntry.new(
      name: event_title_luma(event),
      location: location,
      date: tz.to_local(event.dtstart).iso8601,
      start_time: [tz.to_local(event.dtstart).strftime("%H:%M:%S"), tz.now.strftime("%Z")].join(" "),
      end_time: [tz.to_local(event.dtend).strftime("%H:%M:%S"), tz.now.strftime("%Z")].join(" "),
      url: event.description.scan(/https:\/\/lu.ma\/.+/).first,
      group: self,
    )
  end

  private

    def event_title_meetup(event)
      title = event.title.gsub(name, "").squeeze(" ").gsub(remove || "", "").strip

      duplicate_names = upcoming_events.map(&:title).tally.select { |key, value| value >= 2 }

      if duplicate_names.any?
        title += " #{Date.parse(event.dateTime).strftime("%B %Y")}" if duplicate_names.keys.include?(event.title)
      end

      title = "Meetup #{Date.parse(event.dateTime).strftime("%B %Y")}" if title.blank?

      "#{name} - #{title}".gsub(/^-+|-+$/, "").gsub("- -", "-").gsub("- :", "-").squeeze(" ").strip
    end

    def event_title_luma(event)
      title = event.summary.gsub(name, "").squeeze(" ").gsub(remove || "", "").strip

      duplicate_names = upcoming_events.map(&:summary).tally.select { |key, value| value >= 2 }

      if duplicate_names.any?
        title += " #{tz.to_local(event.dtstart).strftime("%B %Y")}" if duplicate_names.keys.include?(event.summary)
      end

      title = "Meetup #{tz.to_local(event.dtstart).strftime("%B %Y")}" if title.blank?

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
