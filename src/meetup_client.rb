require "pathname"

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

  Schema = GraphQL::Client.load_schema("./src/meetup_graphql_schema.json")
  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
end
