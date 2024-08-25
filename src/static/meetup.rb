require_relative "../static"

class Meetup < FrozenRecord::Base
  def service_id
    if url.start_with?("https://www.meetup.com/") || url.start_with?("https://meetup.com/")
      url.split("/").last
    end
  end
end
