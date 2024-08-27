require "forwardable"
require "tzinfo"

require_relative "../meetups_file_entry"

class AbstractEvent
  extend Forwardable

  attr_reader :object, :group

  def_delegators :meetup_file_entry, :name, :location, :date, :start_time, :end_time, :url

  def initialize(object:, group:)
    @object = object
    @group = group
  end

  def tz
    group.tz || TZInfo::Timezone.get(object.timezone)
  end

  def event_title
    title = event_name.gsub(group.name, "").squeeze(" ").gsub(group.remove || "", "").strip

    duplicate_names = group.upcoming_events.map { |event| event.event_name }.tally.select { |key, value| value >= 2 }

    if duplicate_names.any?
      title += " #{event_start_time.strftime("%B %Y")}" if duplicate_names.keys.include?(event_name)
    end

    title = "Meetup #{event_start_time.strftime("%B %Y")}" if title.blank?

    "#{group.name} - #{title}".gsub(/^-+|-+$/, "").gsub("- -", "-").gsub("- :", "-").squeeze(" ").strip
  end

  def meetup_file_entry
    @meetup_file_entry ||= MeetupsFileEntry.new(
      name: event_title,
      location: event_location,
      date: event_start_time.iso8601,
      start_time: [event_start_time.strftime("%H:%M:%S"), tz.now.strftime("%Z")].join(" "),
      end_time: [event_end_time.strftime("%H:%M:%S"), tz.now.strftime("%Z")].join(" "),
      url: event_url,
      group: group,
    )
  end

  def event_name
    raise "Must implement event_name"
  end

  def event_start_time
    raise "Must implement event_start_time"
  end

  def event_end_time
    raise "Must implement event_end_time"
  end

  def event_location
    raise "Must implement event_location"
  end

  def event_url
    raise "Must implement event_url"
  end

  def service_id
    raise "Must implement service_id"
  end
end
