#!/usr/bin/env ruby

require 'rubygems'  # not necessary for Ruby 1.9
require 'mongo'

# Connect to db. Located here to make it easy to change port etc...
db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'dms_sample')

sporting_events = db[:sporting_event]
sporting_events.find.sort({sport: 1,home_team_name: 1, event_date: 1, away_team_name: 1}).each do |ev|
  puts  ev[:sport] + " " + ev[:home_team_name] + " " + ev[:away_team_name] + " " + ev[:event_date].to_s
end
