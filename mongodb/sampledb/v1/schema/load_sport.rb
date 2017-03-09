#!/usr/bin/env ruby


#
#  Copyright 2017 Amazon.com
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.



require 'rubygems'  # not necessary for Ruby 1.9
require 'mongo'

port = ARGV.first || '27017'

# Connect to db. Located here to make it easy to change port etc...
db = Mongo::Client.new([ '127.0.0.1:' + port ], :database => 'dms_sample')
Mongo::Logger.logger       = ::Logger.new('./log/load_sport.log')
Mongo::Logger.logger.level = ::Logger::INFO

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
