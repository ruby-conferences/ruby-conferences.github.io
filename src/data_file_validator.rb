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
      event_groups_by_date = events.map { |event| [event["name"].split(" - ").first, event["date"]] }

      duplicate_events = event_groups_by_date.tally.select { |group, count| count > 1 }

      duplicate_events.each do |(group, date), count|
        @duplicate_events_error = true
        puts "Meetup Group '#{group}' has #{count} events on #{date.iso8601}"
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
end
