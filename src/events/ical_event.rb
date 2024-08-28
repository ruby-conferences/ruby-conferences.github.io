require_relative "./abstract_event"

class IcalEvent < AbstractEvent
  def event_location
    location = object.location.to_s

    return "Online" if location.start_with?("https://")

    location
  end

  def service_id
    event_url || object.uid
  end

  def event_name
    object.summary
  end

  def event_start_time
    tz.to_local(object.dtstart)
  end

  def event_end_time
    tz.to_local(object.dtend)
  end

  def event_url
    object.url.to_s
  end
end
