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
        events = events.select! { |event| event.title.include?(filter) }
      end

      if exclude.present?
        events = events.reject! { |event| event.title.include?(exclude) }
      end

      events
    end
  end

  def new_events
    upcoming = upcoming_events || []
    upcoming_ids = upcoming.map(&:id)

    new_event_ids = upcoming_ids - existing_event_ids

    new_event_ids.map { |new_id| upcoming.find { |upcoming| new_id == upcoming.id } }
  end

  def existing_events
    Meetup.all.select { |meetup| meetup.url.include?(id) }
  end

  def existing_event_ids
    existing_events.map(&:service_id)
  end

  def openstruct_to_yaml(event)
    timezone = TZInfo::Timezone.get(event.timezone).now.strftime("%Z")

    <<~YAML
      - name: "#{event_title(event)}"
        location: "#{event_to_location(event)}"
        date: #{Date.parse(event.dateTime).iso8601}
        start_time: "#{Time.parse(event.dateTime).strftime("%H:%M:%S")} #{timezone}"
        end_time: "#{Time.parse(event.endTime).strftime("%H:%M:%S")} #{timezone}"
        url: "#{event.eventUrl}"
    YAML
  end

  def openstruct_to_md(event)
    <<~MD
      | [#{event_title(event)}](#{event.eventUrl}) | #{Date.parse(event.dateTime).strftime("%b %d, %Y")} | [#{name}](https://www.meetup.com/#{id}) |
    MD
  end

  def write_new_meetups!
    new_events.sort_by(&:dateTime).select { |event| Date.parse(event.dateTime).between?(Date.today - 1, Date.today + 90) }.each do |event|
      File.write("./_data/meetups.yml", openstruct_to_yaml(event), mode: "a+")
    end
  end

  private

    def event_title(event)
      "#{name} - #{event.title.gsub(name, "").squeeze(" ").strip}"
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
      elsif country
        "#{city}, #{country&.iso_short_name}"
      elsif city
        "#{city}, #{state}, #{country_raw.upcase}"
      else
        "Unknown"
      end
    end
end
