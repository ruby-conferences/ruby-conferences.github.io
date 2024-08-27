require "ostruct"
require "tzinfo"
require "icalendar"

require_relative "./meetup"
require_relative "../static"
require_relative "../meetup_client"
require_relative "../events/luma_event"
require_relative "../events/meetup_event"
require_relative "../queries/events_query"

class MeetupGroup < FrozenRecord::Base
  scope :meetupdotcom, -> { where(service: "meetupdotcom" ) }
  scope :luma, -> { where(service: "luma" ) }

  def upcoming_events
    @upcoming_events ||= fetch_events.tap do |events|
      events.select! { |event| event.name.include?(filter) } if filter.present?
      events.reject! { |event| event.name.include?(exclude) } if exclude.present?
    end
  end

  def new_events
    existing_ids = existing_events.map(&:service_id)

    upcoming_events
      .select { |event| !existing_ids.include?(event.service_id) }
      .select { |event| event.date.between?(Date.today - 1, Date.today + 120) }
      .sort_by { |event| [event.date, event.name] }
  end

  def existing_events
    Meetup.for_group(self)
  end

  def meetupdotcom?
    service == "meetupdotcom"
  end

  def luma?
    service == "luma"
  end

  def tz
    @tz ||= timezone && TZInfo::Timezone.get(timezone)
  end

  private

  def fetch_events
    case service
    when "meetupdotcom"
      fetch_meetup_events
    when "luma"
      fetch_luma_events
    else
      raise "Unsupported service: #{service}"
    end
  end

  def fetch_meetup_events
    result = MeetupClient::Client.query(EventsQuery, variables: { groupId: id })
    events = Array(result.original_hash.dig("data", "groupByUrlname", "unifiedEvents", "edges"))
    events.map { |event| MeetupEvent.new(object: OpenStruct.new(event["node"]), group: self) }
  end

  def fetch_luma_events
    ical_content = Net::HTTP.get(URI(ical_url))
    calendars = Icalendar::Calendar.parse(ical_content)
    calendars.first.events.map { |event| LumaEvent.new(object: event, group: self) }
  end
end
