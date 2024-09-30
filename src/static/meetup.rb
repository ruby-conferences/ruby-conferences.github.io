require_relative "../static"

class Meetup < FrozenRecord::Base
  def self.for_group(group)
    if group.meetupdotcom?
      Meetup.all.select { |meetup| meetup.url.include?(group.id) }
    elsif group.luma?
      Meetup.all.select { |meetup| meetup.name.include?(group.name) }
    elsif group.ical?
      Meetup.all.select { |meetup| meetup.name.include?(group.name) }
    else
      raise "Unsupported service: #{group.service}"
    end
  end

  def service_id
    AbstractEvent.service_id_for_url(url)
  end
end
