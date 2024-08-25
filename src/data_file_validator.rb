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
    end
  end

  def missing_keys?
    @missing_keys_error
  end

  def bonus_keys?
    @bonus_keys_error
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
