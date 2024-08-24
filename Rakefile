#!/usr/bin/env rake
require 'yaml'
require 'date'
require './data_file_validator'
require './meetup_client'

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

task :fetch_meetups do
  File.write("./new_meetups.md", <<~MD)
    ### New Meetups on #{Date.today.strftime("%B %d, %Y")}

    | Title | Date | Meetup Group |
    | ----- | ---- | ------------ |
  MD

  new_events = []

  MeetupGroup.meetupdotcom.each do |group|
    puts "Fetching Meetup.com Group: #{group.id}"

    new_group_events = group.write_new_meetups!

    new_events << new_group_events.zip(
      new_group_events.map { |event| group.openstruct_to_md(event) }
    )
  end

  new_events = new_events.flatten(1).to_h

  new_events.sort_by { |event, _md| event.dateTime }.each do |_event, md|
    File.write("./new_meetups.md", md, mode: "a+")
  end

  new_meetups_from_groups = new_events.group_by { |event, md| event.group["name"] }.transform_values { |value| value.map(&:first) }

  if new_meetups_from_groups.keys.count == 1
    pull_request_title =  "Add #{new_meetups_from_groups.keys.first} #{Date.parse(new_meetups_from_groups.first.last.sort_by(&:dateTime).first.dateTime).strftime("%B %Y")} Meetup"
  elsif new_meetups_from_groups.keys.count > 1
    *groups, last = new_meetups_from_groups.keys
    pull_request_title = "Add #{groups.join(", ")} and #{last} Meetups"
  else
    pull_request_title = "New Meetups on #{Date.today.strftime("%B %d, %Y")}"
  end

  puts "pull_request_title: #{pull_request_title}"
  File.write("./pull_request_title.txt", pull_request_title)

  events = YAML.load_file("./_data/meetups.yml", permitted_classes: [Date])

  events.sort_by! { |event| [event["date"], event["name"]] }

  File.write("./_data/meetups.yml", events.to_yaml.gsub("- name:", "\n- name:"))
end

task default: [:build, :verify_data, :verify_html]
