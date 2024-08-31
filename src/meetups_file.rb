require "date"
require "yaml"
require "pathname"

require_relative "./meetups_file_entry"
require_relative "./static/meetup_group"

class MeetupsFile
  PATH = Pathname.new("./_data/meetups.yml")

  def self.read
    new(content: PATH.read)
  end

  def initialize(content:)
    yaml = YAML.load(content, permitted_classes: [Date])
    @events = yaml.map { |entry| MeetupsFileEntry.from_yaml_item(entry) }

    @new_events = []
    @updated_events = []
    @removed_events = []
    @cancelled_events = []
  end

  def find_by(service_id: nil, url: nil)
    if service_id
      @events.find { |event| event.service_id == service_id }
    elsif url
      @events.find { |event| event.service_id == url.split("/").last }
    else
      raise "Please provide a service_id or url"
    end
  end

  def fetch_group!(group)
    puts "Fetching #{group.service} Group: #{group.id}"

    group.new_events.map { |event| event.meetup_file_entry }.each do |event|
      @new_events << event
      @events << event
      puts "New Meetup: #{event.name} - #{event.date}"
    end

    group.cancelled_events.map { |event| event.meetup_file_entry }.each do |event|
      event_entry = find_by(url: event.url)

      if event_entry && event != event_entry
        @cancelled_events << event
        @events[@events.index(event_entry)] = event
        puts "Cancelled Meetup: #{event.name} - #{event.date}"
      end
    end

    group.upcoming_events.map { |event| event.meetup_file_entry }.each do |event|
      event_entry = find_by(url: event.url)

      if event_entry && event != event_entry
        @updated_events << event
        @events[@events.index(event_entry)] = event
        puts "Changed Meetup: #{event.name} - #{event.date}"
      end
    end

    group.missing_events.map { |event| MeetupsFileEntry.from_yaml_item(event) }.each do |event|
      @removed_events << event
      @events.delete(event)
      puts "Removed Meetup: #{event.name} - #{event.date}"
    end

    puts
  end

  def fetch!(id = nil)
    groups = MeetupGroup.all
    groups = groups.where(id: id) if id

    groups.each { |group| fetch_group!(group) }

    puts "New Events: #{@new_events.count}"
    puts "Updated Events: #{@updated_events.count}"

    write_pull_request_title!
    write_pull_request_body!
  end

  def write_pull_request_title!
    if (@new_events.one? && @updated_events.none?) || (@new_events.none? && @updated_events.one?)
      if @new_events.one?
        event = @new_events.first
        verb = "Add"
      else
        event = @updated_events.first
        verb = "Update"
      end

      pull_request_title = "#{verb} #{event.group.name} #{event.date.strftime("%B %Y")} Meetup"

    elsif (@new_events.any? && @updated_events.none?) || (@new_events.none? && @updated_events.any?)
      if @new_events.any?
        groups = @new_events.map(&:group).map(&:name).uniq.sort
        verb = "Add"
      else
        groups = @updated_events.map(&:group).map(&:name).uniq.sort
        verb = "Update"
      end

      *first, last = groups

      if first.count > 5
        last = "more"
        first = first.first(5)
      end

      pull_request_title = "#{verb} #{first.join(", ")} and #{last} Meetups"

    elsif @new_events.any? && @updated_events.any?
      *first, last = groups = (@new_events + @updated_events).map(&:group).map(&:name).uniq.sort

      if first.count > 5
        last = "more"
        first = first.first(5)
      end

      pull_request_title = "Meetup Updates from #{first.join(", ")} and #{last}"

    else
      pull_request_title = "Meetup Updates on #{Date.today.strftime("%B %d, %Y")}"
    end

    puts "Pull Request Title: #{pull_request_title}"
    File.write("./pull_request_title.txt", pull_request_title)
  end

  def write_pull_request_body!
    new_meetups = @new_events.any? ? <<~MD : ""
      #### New Meetups

      | Title | Date |
      | ----- | ---- |
      #{@new_events.sort_by { |event| [event.date, event.name] }.map(&:to_md).join}
    MD

    updated_meetups = @updated_events.any? ? <<~MD : ""
      #### Updated Meetups

      | Title | Date |
      | ----- | ---- |
      #{@updated_events.sort_by { |event| [event.date, event.name] }.map(&:to_md).join}
    MD

    removed_meetups = @removed_events.any? ? <<~MD : ""
      #### Removed Meetups

      | Title | Date |
      | ----- | ---- |
      #{@removed_events.sort_by { |event| [event.date, event.name] }.map(&:to_md).join}
    MD

    cancelled_meetups = @cancelled_events.any? ? <<~MD : ""
      #### Cancelled Meetups

      | Title | Date |
      | ----- | ---- |
      #{@cancelled_events.sort_by { |event| [event.date, event.name] }.map(&:to_md).join}
    MD

    File.write("./pull_request_body.md", <<~MD)
      ### Meetups Update from #{Date.today.strftime("%B %d, %Y")}

      #{new_meetups}
      #{updated_meetups}
      #{removed_meetups}
      #{cancelled_meetups}
    MD
  end

  def write!
    PATH.write(@events.sort_by { |event| [event.date, event.name] }.map(&:to_hash).to_yaml.gsub("- name:", "\n- name:"))
  end
end
