MeetupsFileEntry = Data.define(:name, :location, :date, :start_time, :end_time, :url) do
  attr_reader :group

  def initialize(name:, location:, date:, start_time:, end_time:, url:, group: nil)
    date = date.is_a?(Date) ? date : Date.parse(date)
    @group = group

    super(name:, location:, date:, start_time:, end_time:, url:)
  end

  def self.from_yaml_item(hash)
    new(
      name: hash["name"],
      location: hash["location"],
      date: hash["date"],
      start_time: hash["start_time"],
      end_time: hash["end_time"],
      url: hash["url"],
      group: hash["group"]
    )
  end

  def self.from_frozen_record(record)
    from_yaml_item(record.attributes)
  end

  def service_id
    if url.start_with?("https://www.meetup.com/") || url.start_with?("https://meetup.com/")
      url.split("/").last
    end
  end

  def to_hash
    {
      "name" => name,
      "location" => location,
      "date" => date,
      "start_time" => start_time,
      "end_time" => end_time,
      "url" => url,
    }
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
