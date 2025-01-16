MeetupsFileEntry = Data.define(:name, :location, :date, :start_time, :end_time, :url, :status) do
  attr_reader :group

  def initialize(name:, location:, date:, start_time:, end_time:, url:, status: nil, group: nil)
    date = date.is_a?(Date) ? date : Date.parse(date)
    @group = group
    super(name:, location:, date:, start_time:, end_time:, url:, status:)
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
      status: hash["status"]
    )
  end

  def service_id
    AbstractEvent.service_id_for_url(url)
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
