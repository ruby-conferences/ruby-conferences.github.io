#!/usr/bin/env rake
require 'yaml'
require './data_file_validator'

desc "Build Jekyll site"
task :build do
  exit 1 unless system "bundle exec jekyll build"
end

desc "Verify generated HTML"
task :verify_html do
  exit 2 unless system "bundle exec htmlproofer ./_site"
end

desc "Verify event data"
task :verify_data do
  data_files = [
    {
      filename: :past,
      allowed_keys: ["name", "location", "dates", "url", "twitter", "video_link"]
    }, {
      filename: :current,
      allowed_keys: ["name", "location", "dates", "url", "twitter", "reg_phrase", "reg_date", "cfp_phrase", "cfp_date"]
    }
  ]

  validators = data_files.map do |data_file|
    data = YAML.load File.read "_data/#{data_file[:filename]}.yml"
    DataFileValidator.validate(data, data_file[:allowed_keys])
  end

  exit 3 if validators.any? &:missing_keys?
  exit 4 if validators.any? &:bonus_keys?

  events = validators.map(&:events).flatten
  dates = events.map { |event| Date.parse event["dates"].gsub(/[-&][^,]+/, '') }
  exit 5 unless dates.sort == dates
end

task default: [:build, :verify_html, :verify_data]
