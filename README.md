# Ruby Conferences

[RubyConferences.org][r] is a simple list of Ruby conferences, published
collaboratively with the Ruby community. Updates are sometimes posted to
[@rubyconferences][t].

[r]: https://rubyconferences.org/
[t]: https://twitter.com/rubyconferences

## ICS Calendar Feeds

This page publishes `.ics` feed files for inclusion in personal calendars:

- [`calendar.ics`](https://rubyconferences.org/calendar.ics) for the events only
- [`cfp.ics`](https://rubyconferences.org/cfp.ics) for the CFP open/close dates

## RSS Feed

This page publishes an RSS feed so you can stay up to date with newly announced Ruby conferences.

- [`feed.xml`](https://rubyconferences.org/feed.xml) for RSS Readers


## Eligible Conferences

Focus is a goal of this project and as a result, only conferences that are
specifically for Ruby are listed. That means that if a conference covers Ruby,
but is not specifically for Rubyists, then it is left out.

A good rule of thumb for whether a conference should be included is if its name
includes either Ruby or Rails and how it describes itself. A conference that
describes itself as a "Conference on Web Development" might be an awesome event,
but it's probably not a Ruby conference.

## Contributing

The list of events is driven by the conferences file in the `_data` directory - if you have an update for those things, just change the YAML and send a PR.

**Conferences**

The file to be changed is `_data/conferences.yml`.
This file is order-dependent. Put your conference in the YAML file sorted by its `start_date`.

Here is a list of the keys that can be used:

* `name`: The official name of the event
* `location`: When the event is in the US, this would be "City, State", for any
  other country, use "City, Country".
* `start_date`: The date of the first day of the event - ISO8601 formatted (yyyy-mm-dd).
* `end_date`: The date of the last day of the event - ISO8601 formatted (yyyy-mm-dd). For one day events this should equal `start_date`.
* `url`: The url for the event.
* `twitter`: The twitter handle for the event, you can leave off the "@".
* `mastodon`: The mastodon url for the event, for example https://ruby.social/@conferencehandle

Extra keys for the upcoming events:

* `reg_phrase`: Typically you want to put "Registration open" here.
* `reg_date`: If there is a registration deadline, enter that here - ISO8601 formatted (yyyy-mm-dd).
* `cfp_open_date`: The date when the CFP was opened - ISO8601 formatted (yyyy-mm-dd).
* `cfp_close_date`: If there is a CFP deadline, enter that here - ISO8601 formatted (yyyy-mm-dd).
* `cfp_link`: A link to the CFP submission page.
* `status`:  Typically you want to put "Cancelled", "Postponed" or "To be announced" here.
* `date_precision`: Controls the precision of the `start_date` and `end_date` when the conference dates aren't announced just yet, but it's confirmed that the conference is happening. Possible values: `full` (implicit default), `month` or `year`. The `start_date` and `end_date` fields still need to be fully formatted ISO8601 dates, you can put the last day of the month/year in it so it also gets ordered properly.
* `announced_on`: The date on which the conference was announced - ISO8601 formatted (yyyy-mm-dd). This date is used as the publishing date for the [RSS feed](https://rubyconferences.org/feed.xml) so people can stay up to date with newly announced conferences.

Extra keys for the past events:

* `video_link`: A url to the videos for the event.

**Meetups**

The file to be changed is `_data/meetups.yml`.
This file is order-dependent. Put your meetup in the YAML file sorted by its date.
Otherwise, put the meetup at the end of the YAML file and run `rake sort_meetups`.
Please make sure to preserve any comments in the YAML file.

Here is a list of the keys that can be used:

* `name`: The official name of the event
* `location`: When the event is in the US, this would be "City, State", for any
  other country, use "City, Country".
* `date`: The date of the event - ISO8601 formatted (yyyy-mm-dd).
* `start_time`: The start time of the event - formatted as (hh:mm:ss ZZZ)
  * hh - between 0 and 23
  * mm - between 0 and 59
  * ss - between 0 and 59
  * ZZZ - timezone (e.g. CDT or EST)
* `end_time`: The end time of the event - ISO8601 formatted as (hh:mm:ss ZZZ) using same values as `start_time`
* `url`: The url for the event.
* `status`:  Typically you want to put "Cancelled" or "Postponed" here.

## Getting started

We build the site with [Jekyll](https://jekyllrb.com/).

Install Ruby, then:
```
cd ruby-conferences.github.io
bundle install
bundle exec jekyll serve
```
and point your browser at http://localhost:4000/

## License

The design of the site is copyrighted by Cameron Daigle.

All other original work uses the Creative Commons
[Attribution-NonCommercial-ShareAlike 4.0 International License][l].

[l]: https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en_US
