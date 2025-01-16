require_relative "./abstract_event"

class IcalEvent < AbstractEvent
  def event_location
    location = object.location.to_s

    return "Online" if location.start_with?("https://") || location == "Online" || location == "Virtual" || event_name.include?("Virtual") || event_name.include?("Zoom")

    return group.default_location if group.default_location

    location
  end

  def service_id
    event_url || object.uid
  end

  def event_name
    object.summary.force_encoding("utf-8")
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
