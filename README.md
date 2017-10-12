# Ruby Conferences

[![Build Status](https://travis-ci.org/ruby-conferences/ruby-conferences.github.io.svg)][travis]

[travis]: https://travis-ci.org/ruby-conferences/ruby-conferences.github.io

[RubyConferences.org][r] is a simple list of Ruby conferences, published
collaboratively with the Ruby community. Updates are sometimes posted to
[@rubyconferences][t].

[r]: http://rubyconferences.org/
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

The list of events is driven by the two files in the `_data` directory - if you
have an update for those things, just change the YAML and send a PR.

Here is a list of the keys that can be used:

* `name`: The official name of the event
* `location`: When the event is in the US, this would be "City, State", for any
  other country, use "City, Country".
* `dates`: The dates for the event - use "Month Day, Year" format with multi-day
  events looking like "1-2".
* `url`: The url for the event.
* `twitter`: The twitter handle for the event, you can leave off the "@".

Extra keys for the current list:

* `reg_phrase`: Typically you want to put "Registration open" here.
* `reg_date`: If there is a registration deadline, enter that here.
* `cfp_phrase`: Typically you want to put "CFP open" here.
* `cfp_date`: If there is a cfp deadline, enter that here.

Extra keys for the past list:

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

[l]: http://creativecommons.org/licenses/by-nc-sa/4.0/deed.en_US.
