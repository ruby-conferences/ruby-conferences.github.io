require_relative "../static"

class Meetup < FrozenRecord::Base
  def self.for_group(group)
    if group.meetupdotcom?
      Meetup.all.select { |meetup| meetup.url.include?(group.id) }
    elsif group.luma?
      Meetup.all.select { |meetup| meetup.name.include?(group.name) }
    else
      raise "Unsupported service: #{group.service}"
    end
  end

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
