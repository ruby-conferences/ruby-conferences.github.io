#!/usr/bin/env rake
require 'yaml'

class DataFileValidator
  attr_accessor :events

  def self.validate(events)
    new(events).tap &:validate
  end

  def initialize(events)
    @events = events
  end

  def validate
    for event in events
      missing_keys = required_keys - event.keys
      unless missing_keys.empty?
        puts "Missing keys: #{missing_keys}"
        puts event
        @missing_keys_error = true
      end
    end
  end

  def missing_keys?
    @missing_keys_error
  end

  private

  def required_keys
    ["dates", "name", "location"]
  end
end

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
      filename: :past
    }, {
      filename: :current
    }
  ]

  validators = data_files.map do |data_file|
    data = YAML.load File.read "_data/#{data_file[:filename]}.yml"
    DataFileValidator.validate(data)
  end

  exit 3 if validators.any? &:missing_keys?

  events = validators.map(&:events).flatten
  dates = events.map { |event| Date.parse event["dates"].gsub(/[-&][^,]+/, '') }
  exit 4 unless dates.sort == dates
end

task default: [:build, :verify_html, :verify_data]
