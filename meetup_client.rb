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
            group {
              id
              name
              country
              state
              city
            }
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

  def upcoming_events
    result = MeetupClient::Client.query(EventsQuery, variables: { groupId: id })

    @upcoming_events_result = result

    events = Array(result.original_hash.dig("data", "groupByUrlname", "unifiedEvents", "edges"))
    events = events.map { |event| OpenStruct.new(event["node"]) }

    if filter.present?
      events = events.select! { |event| event.title.include?(filter) }
    end

    if exclude.present?
      events = events.reject! { |event| event.title.include?(exclude) }
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
    timezone = TZInfo::Timezone.get(event.timezone).now.strftime("%Z")

    <<~YAML
      - name: "#{event_title(event)}"
        location: "#{event_to_location(event)}"
        date: #{Date.parse(event.dateTime).iso8601}
        start_time: "#{Time.parse(event.dateTime).strftime("%H:%M:%S")} #{timezone}"
        end_time: "#{Time.parse(event.endTime).strftime("%H:%M:%S")} #{timezone}"
        url: "#{event.eventUrl}"
    YAML
  end

  def openstruct_to_md(event)
    <<~MD
      | [#{event_title(event)}](#{event.eventUrl}) | #{Date.parse(event.dateTime).strftime("%b %d, %Y")} | [#{name}](https://www.meetup.com/#{id}) |
    MD
  end

  def write_new_meetups!
    new_events.sort_by(&:dateTime).select { |event| Date.parse(event.dateTime).between?(Date.today - 1, Date.today + 90) }.each do |event|
      File.write("./_data/meetups.yml", openstruct_to_yaml(event), mode: "a+")
    end
  end

  private

    def event_title(event)
      "#{name} - #{event.title.gsub(name, "").squeeze(" ").strip}"
    end

    def event_to_location(event)
      city = event.venue.dig("city") || event.group.dig("city")
      state = event.venue.dig("state") || event.group.dig("state")
      country_raw = event.venue.dig("country") || event.group.dig("country")

      country = ISO3166::Country.new(country_raw)

      if event.isOnline
        "Online"
      elsif country.alpha2 == "US"
        "#{city}, #{state.upcase}"
      elsif country
        "#{city}, #{country&.iso_short_name}"
      elsif city
        "#{city}, #{state}, #{country_raw.upcase}"
      else
        "Unknown"
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
