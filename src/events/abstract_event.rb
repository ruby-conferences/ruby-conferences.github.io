require "forwardable"
require "tzinfo"

require_relative "../meetups_file_entry"

class AbstractEvent
  extend Forwardable

  attr_reader :object, :group

  def_delegators :meetup_file_entry, :name, :location, :date, :start_time, :end_time, :url

  def self.service_id_for_url(url)
    return nil if url.nil?
    return nil if url.blank?

    if url.start_with?("https://www.meetup.com/") || url.start_with?("https://meetup.com/")
      return url.split("/").last
    end

    if url.start_with?("https://lu.ma/")
      return url.split("/").last
    end

    url
  end

  def initialize(object:, group:)
    @object = object
    @group = group
  end

  def tz
    group.tz || TZInfo::Timezone.get(object.timezone)
  end

  def event_title
    title = event_name

    Array(group.remove || "").each do |remove|
      title = title.gsub(remove, "")
    end

    title = title.gsub(group.name, "").squeeze(" ").strip

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
      date: event_date.iso8601,
      start_time: [event_start_time.strftime("%H:%M:%S"), tz.now.strftime("%Z")].join(" "),
      end_time: [event_end_time.strftime("%H:%M:%S"), tz.now.strftime("%Z")].join(" "),
      url: event_url.gsub(/\/$/, ""),
      group: group,
      status: event_status
    )
  end

  def service_id
    self.class.service_id_for_url(event_url)
  end

  def event_date
    event_start_time.to_date
  end

  def event_status
    if event_name.downcase.include?("cancelled") || event_name.downcase.include?("canceled")
      return "cancelled"
    end

    if event_name.downcase.include?("postponed")
      return "postponed"
    end

    nil
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
end
