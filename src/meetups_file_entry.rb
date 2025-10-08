MeetupsFileEntry = Data.define(:name, :location, :date, :start_time, :end_time, :url, :status, :service) do
  attr_reader :group

  def initialize(name:, location:, date:, start_time:, end_time:, url:, status: nil, service: nil, group: nil)
    date = date.is_a?(Date) ? date : Date.parse(date)
    @group = group
    service ||= detect_service(url)
    super(name:, location:, date:, start_time:, end_time:, url:, status:, service:)
  end

  def self.from_yaml_item(hash)
    new(
      name: hash["name"],
      location: hash["location"],
      date: hash["date"],
      start_time: hash["start_time"],
      end_time: hash["end_time"],
      url: hash["url"],
      group: hash["group"],
      status: hash["status"],
      service: hash["service"]
    )
  end

  def service_id
    AbstractEvent.service_id_for_url(url)
  end

  def detect_service(url)
    return nil unless url

    case url
    when /meetup\.com/
      "meetup"
    when /lu\.ma/, /luma\.com/
      "luma"
    else
      nil
    end
  end

  def to_hash
    hash = {
      "name" => name,
      "location" => location,
      "date" => date,
      "start_time" => start_time,
      "end_time" => end_time,
      "url" => url,
    }

    hash["status"] = status if status.present?
    hash["service"] = service if service.present?

    hash
  end

  def to_md
    <<~MD
      | [#{name}](#{url}) | #{date.strftime("%b %d, %Y")} |
    MD
  end

  def to_yaml(options = {})
    to_hash.to_yaml(options)
  end
end
