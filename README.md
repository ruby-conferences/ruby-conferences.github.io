# Ruby Conferences

[![Build Status](https://travis-ci.org/ruby-conferences/ruby-conferences.github.io.svg)][travis]

[travis]: https://travis-ci.org/ruby-conferences/ruby-conferences.github.io

[RubyConferences.org][r] is a simple list of Ruby conferences, published
collaboratively with the Ruby community. Updates are sometimes posted to
[@rubyconferences][t].

[r]: https://rubyconferences.org/
[t]: https://twitter.com/rubyconferences

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

The file to be changed is `_data/conferences.yml`. It is NOT order-dependent.
Put your conference in the YAML file at the end.
The page will sort the conferences by `start_date`.

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
* `cfp_phrase`: Typically you want to put "CFP open" here. If you also provide a `cfp_date` then you may prefer to write "CFP closes" so the site will render for example "CFP closes in 17 days".
* `cfp_date`: If there is a cfp deadline, enter that here - ISO8601 formatted (yyyy-mm-dd).

Extra keys for the past events:

* `video_link`: A url to the videos for the event.

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
