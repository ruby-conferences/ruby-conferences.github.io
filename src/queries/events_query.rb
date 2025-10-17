require_relative "../meetup_client"

eventConnection = <<-GRAPHQL
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
GRAPHQL

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
      upcomingEvents(input: { first: 50 }, filter: { includeCancelled: true }, sortOrder: ASC) {
        #{eventConnection}
      }
    }
  }
  GRAPHQL
)

PastEventsQuery = MeetupClient::Client.parse(<<-GRAPHQL
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
      pastEvents(input: { first: 1000 }, sortOrder: ASC){
        #{eventConnection}
      }
    }
  }
  GRAPHQL
)
