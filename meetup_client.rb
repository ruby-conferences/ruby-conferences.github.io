require "yaml"
require "pathname"
require "ostruct"

require "tzinfo"
require "countries"
require "frozen_record"

require "graphql/client"
require "graphql/client/http"

module MeetupClient
  BASE = "https://api.meetup.com/gql".freeze
  HTTP = GraphQL::Client::HTTP.new(BASE) do
    def headers(context)
      {
        Authorization: "Bearer #{ENV["MEETUP_API_TOKEN"]}",
        "Content-Type": "application/json",
      }
    end
  end

  Schema = GraphQL::Client.load_schema("./meetup_graphql_schema.json")
  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
end

EventsQuery = MeetupClient::Client.parse(<<-GRAPHQL
  query ($groupId: String!) {
    groupByUrlname(urlname: $groupId) {
      id
      logo {
        id
        baseUrl
        preview
        source
      }
      name
      country
      state
      city
      unifiedEvents(sortOrder: ASC) {
        count
        edges {
          cursor
          node {
            id
            title
            eventUrl
            shortDescription
            description
            onlineVenue {
              type
              url
            }
            venue {
              address
              city
              state
              country
            }
            host {
              id
              name
              email
            }
            status
            dateTime
            endTime
            duration
            timezone
            createdAt
            eventType
            isOnline
          }
        }
      }
    }
  }
  GRAPHQL
)

FrozenRecord::Base.auto_reloading = true
FrozenRecord::Base.base_path = "./_data"

class Conference < FrozenRecord::Base
end

class MeetupGroup < FrozenRecord::Base
  scope :meetupdotcom, -> { where(service: "meetupdotcom" ) }
  scope :luma, -> { where(service: "luma" ) }

  def location
    unless @upcoming_events_result
      upcoming_events
    end

    group = @upcoming_events_result.dig("data", "groupByUrlname")

    city = group.dig("city")
    state = group.dig("state")
    country = group.dig("country")

    if country == "us"
      "#{city}, #{state.upcase}"
    else
      country = ISO3166::Country.new(country)
      "#{city}, #{country&.iso_long_name}"
    end
  end

  def upcoming_events
    result = MeetupClient::Client.query(EventsQuery, variables: { groupId: id })

    @upcoming_events_result = result

    events = Array(result.original_hash.dig("data", "groupByUrlname", "unifiedEvents", "edges"))
    events = events.map { |event| OpenStruct.new(event["node"]) }

    if filter.present?
      events = events.select! { |event| event.title.include?(filter) }
    end

    events
  end

  def new_events
    upcoming = upcoming_events
    upcoming_ids = upcoming.map(&:id)

    new_event_ids = upcoming_ids - existing_event_ids

    new_event_ids.map { |new_id| upcoming.find { |upcoming| new_id == upcoming.id } }
  end

  def existing_events
    Meetup.all.select { |meetup| meetup.url.include?(id) }
  end

  def existing_event_ids
    existing_events.map(&:service_id)
  end

  def openstruct_to_yaml(event)
    city = event.venue.dig("city")
    state = event.venue.dig("state")
    country = event.venue.dig("country")

    if event.isOnline
      meetup_location = "Online"
    elsif country == "us"
      meetup_location = "#{city}, #{state.upcase}"
    elsif country && country != "us"
      country = ISO3166::Country.new(country)
      meetup_location = "#{city}, #{country&.iso_long_name}"
    else
      meetup_location = location
    end

    timezone = TZInfo::Timezone.get(event.timezone).now.strftime("%Z")

    <<~YAML
      - name: "#{name} - #{event.title.gsub(name, "").squeeze(" ").strip}"
        location: "#{meetup_location}"
        date: #{Date.parse(event.dateTime).iso8601}
        start_time: "#{Time.parse(event.dateTime).strftime("%H:%M:%S")} #{timezone}"
        end_time: "#{Time.parse(event.endTime).strftime("%H:%M:%S")} #{timezone}"
        url: "#{event.eventUrl}"
    YAML
  end

  def write_new_meetups!
    new_events.each do |event|
      next unless Date.parse(event.dateTime).between?(Date.today - 1, Date.today + 90)

      File.write("./_data/meetups.yml", openstruct_to_yaml(event), mode: "a+")
    end
  end
end

class Meetup < FrozenRecord::Base
  def service_id
    if url.start_with?("https://www.meetup.com/") || url.start_with?("https://meetup.com/")
      url.split("/").last
    end
  end
end
