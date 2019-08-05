class DataFileValidator
  attr_accessor :events

  def self.validate(events, allowed_keys)
    new(events, allowed_keys).tap &:validate
  end

  def initialize(events, allowed_keys)
    @events = events
    @allowed_keys = allowed_keys
  end

  def validate
    for event in events
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

  def required_keys
    ["start_date", "end_date", "name", "location"]
  end
end
