#!/usr/bin/env ruby

require 'rubygems'  # not necessary for Ruby 1.9
require 'mongo'

# Connect to db. Located here to make it easy to change port etc...
db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'dms_sample')

bb = {:name => "baseball", :description => "A sport with 9 players, bats, and balls - what could possibly go wrong?", 
      :league => "MLB", :league_name => "Major League Baseball"}

fb = {:name => "football", :description => "Teams of 11 players attempt to move an oblong ball 100 yards while beating the snot out of each other.", 
      :league => "NFL", :league_name => "National Football League"}

bb[:divisions] = [
  {:name => "AL East", :description => "American League East"},
  {:name => "AL Central", :description => "American League Central"},
  {:name => "AL West", :description => "American League West"},
  {:name => "NL East", :description => "National League East"},
  {:name => "NL Central", :description => "National League Central"},
  {:name => "NL West", :description => "National League West"}
]

fb[:divisions] = [
  {:name => "AFC East", :description => "American Football Conference East"},
  {:name => "AFC West", :description => "American Football Conference West"},
  {:name => "AFC North", :description => "American Football Conference North"},
  {:name => "AFC South", :description => "American Football Conference South"},
  {:name => "NFC East", :description => "National Football Conference East"},
  {:name => "NFC West", :description => "National Football Conference West"},
  {:name => "NFC North", :description => "National Football Conference North"},
  {:name => "NFC South", :description => "National Football Conference South"}
]

sports = []

sports << fb
sports << bb

sport_tab = db[:sport]
result = sport_tab.drop
result = sport_tab.insert_many(sports)
puts "inserted: " + result.inserted_count.to_s + " sport records"
