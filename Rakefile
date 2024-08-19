#!/usr/bin/env rake
require 'yaml'
require 'date'
require './data_file_validator'

desc "Build Jekyll site"
task :build do
  exit 1 unless system "bundle exec jekyll build"
end

desc "Verify generated HTML"
task :verify_html do
  exit 2 unless system "bundle exec htmlproofer ./_site"
end

desc "Verify event conferences"
task :verify_conferences do
  allowed_keys = [
    "name",
    "location",
    "start_date",
    "end_date",
    "url",
    "twitter",
    "mastodon",
    "reg_phrase",
    "reg_date",
    "cfp_open_date",
    "cfp_close_date",
    "cfp_link",
    "status",
    "date_precision",
    "video_link",
    "announced_on"
  ]
  data = YAML.load_file("_data/conferences.yml", permitted_classes: [Date])
  validator = DataFileValidator.validate(data, allowed_keys)

  exit 3 if validator.missing_keys?
  exit 4 if validator.bonus_keys?

  events = validator.events
  dates = events.map { |event| event["start_date"] }
  exit 5 unless dates.sort == dates
end

task :verify_meetups do
  allowed_keys = [
    "name",
    "location",
    "date",
    "start_time",
    "end_time",
    "url",
    "twitter",
    "mastodon",
    "video_link"
  ]
  data = YAML.load_file("_data/meetups.yml", permitted_classes: [Date])
  validator = DataFileValidator.validate(data, allowed_keys, :meetup)

  exit 3 if validator.missing_keys?
  exit 4 if validator.bonus_keys?

  events = validator.events
  dates = events.map { |event| event["start_date"] }
  exit 5 unless dates.sort == dates
end

task default: [:build, :verify_data, :verify_html]
