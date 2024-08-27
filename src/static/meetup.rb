require_relative "../static"

class Meetup < FrozenRecord::Base
  def service_id
    if url.start_with?("https://www.meetup.com/") || url.start_with?("https://meetup.com/")
      return url.split("/").last
    end

    if url.start_with?("https://lu.ma/")
      return url.split("/").last
    end

    nil
  end
end
