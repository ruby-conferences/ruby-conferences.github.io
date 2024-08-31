require_relative "../meetup_client"

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
