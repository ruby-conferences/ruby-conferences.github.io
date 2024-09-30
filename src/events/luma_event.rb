require_relative "./abstract_event"

class LumaEvent < AbstractEvent
  def event_location
    location = object.location.to_s

    if location.start_with?("https://")
      location = "Online"
    else
      location_parts = location.split(",").map(&:strip)
      location_parts.delete("USA")

      if (match = location_parts.last.match(/([A-Z]{2}) (\d{4,5})/))
        location_parts.delete(location_parts.last)
        location_parts << match[1]
      end

      location = location_parts.last(2).join(", ").strip
    end
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
    object.description.scan(/https:\/\/lu.ma\/.+/).first
  end
end
