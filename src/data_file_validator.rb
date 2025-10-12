class DataFileValidator
  attr_accessor :events

  def self.validate(events, allowed_keys, type = :conference)
    new(events, allowed_keys, type).tap &:validate
  end

  def initialize(events, allowed_keys, type = :conference)
    @events = events
    @allowed_keys = allowed_keys
    @type = type
  end

  def validate
    requires_announced_on_after = Date.parse("2024-08-01")

    events.each do |event|
      missing_keys = required_keys - event.keys
      unless missing_keys.empty?
        puts "Missing keys: #{missing_keys}"
        puts event
        @missing_keys_error = true
      end

      bonus_keys = event.keys - @allowed_keys
      unless bonus_keys.empty?
        puts "Bonus keys: #{bonus_keys}"
        puts event
        @bonus_keys_error = true
      end

      if @type == :conference && event["start_date"].after?(requires_announced_on_after) && !event.key?("announced_on")
        @missing_announced_on_date_error = true

        puts "Conference '#{event["name"]}' doesn't have an 'announced_on' key."
      end
    end

    if @type == :meetup
      events_by_group_and_date = events.group_by { |event|
        [event["name"].split(" - ").first, event["date"]]
      }

      events_by_group_and_date.each do |(group, date), group_events|
        next if group_events.size == 1

        services = group_events.map { |event|
          event["service"] || detect_service_from_url(event["url"])
        }.compact

        if services.uniq.size == services.size
          next
        end

        @duplicate_events_error = true
        duplicate_services = services.group_by { |s| s }.select { |_, v| v.size > 1 }.keys
        puts "Meetup Group '#{group}' has multiple events on #{date.iso8601} from the same service(s): #{duplicate_services.join(', ')}"
      end
    end
  end

  def missing_keys?
    @missing_keys_error
  end

  def bonus_keys?
    @bonus_keys_error
  end

  def duplicate_events?
    @duplicate_events_error
  end

  def missing_announced_on_date?
    @missing_announced_on_date_error
  end

  private

  def required_keys(type = @type)
    case type
    when :conference
      ["start_date", "end_date", "name", "location"]
    when :meetup
      ["date", "start_time", "end_time", "name", "location"]
    else
      raise "required_keys: unknown type '#{type}'"
    end
  end

  def detect_service_from_url(url)
    return nil unless url

    case url
    when /meetup\.com/
      "meetup"
    when /lu\.ma/, /luma\.com/
      "luma"
    else
      nil
    end
  end
end
