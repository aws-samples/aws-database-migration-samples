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
Mongo::Logger.logger       = ::Logger.new('./log/generate_sporting_events.log')
Mongo::Logger.logger.level = ::Logger::INFO

sporting_event = db[:sporting_event]
result = sporting_event.drop()
sporting_events = []

sport_team = db[:sport_team]

##############################################################################################
# The following generates the mlb sporting season
##############################################################################################

team1 = sport_team.find({:sport => 'baseball'}, {:fields =>  [:sport, :name, :home_field_id]})

team1.each do |t1|

  # start on the closest saturday to mar 31 of the current year 
  event_date = Date.new(Date.today.year,3,31)
  until event_date.saturday? do
    event_date += 1
  end

  team2 = sport_team.find({:sport => 'baseball', :_id => {"$gt" => t1[:_id]}}, {:fields =>  [:sport, :name, :home_field_id]})
  team3 = sport_team.find({:sport => 'baseball', :_id => {"$lt" => t1[:_id]}}, {:fields =>  [:sport, :name, :home_field_id]})

  team2.each do |t2|
    sporting_events << { :sport => t1[:sport], :home_team_oid => t1[:_id], :home_team_name => t1[:name],
                         :away_team_oid => t2[:_id], :away_team_name => t2[:name], :location_oid => t1[:home_field_id], 
                         :event_date => event_date.to_time + (12*60*60) + rand(1..7)*60*60 }
    event_date += 7
  end
 
  team3.each do |t3|
    sporting_events << { :sport => t1[:sport], :home_team_oid => t1[:_id], :home_team_name => t1[:name],
                         :away_team_oid => t3[:_id], :away_team_name => t3[:name], :location_oid => t1[:home_field_id], 
                         :event_date => event_date.to_time + (12*60*60) + rand(1..7)*60*60 }
    event_date += 7 
   end
end

result = sporting_event.insert_many(sporting_events)
puts "inserted: " + result.inserted_count.to_s + " sporting events"


##############################################################################################
# The following generates the nfl sporting season
##############################################################################################

sport_data = db[:sport]
sport = sport_data.find({ :name => 'football' }).first
divisions = sport[:divisions].collect{ |d| d[:name] }.sort


# Inter division play - each team plays the other twice once at home, once away
last_event_date = Date.new   # to capture last event date of each block of events

divisions.each do |division|
  team1 = sport_team.find({:sport => 'football',:division => division }, {:fields =>  [:sport, :name, :home_field_id]})

  team1.each do |t1|

    # start on first sunday in september
    event_date = Date.new(Date.today.year,9,1)
    until event_date.sunday? do
      event_date += 1
    end

    # Get non team1 teams
    team2 = sport_team.find({:sport => 'football', :division => division, :_id => {"$gt" => t1[:_id]}}, {:fields =>  [:sport, :name, :home_field_id]})
    team3 = sport_team.find({:sport => 'football', :division => division, :_id => {"$lt" => t1[:_id]}}, {:fields =>  [:sport, :name, :home_field_id]})
  
    team2.each do |t2|
      sporting_events << { :sport => t1[:sport], :home_team_oid => t1[:_id], :home_team_name => t1[:name],
                           :away_team_oid => t2[:_id], :away_team_name => t2[:name], :location_oid => t1[:home_field_id],
                           :event_date => event_date.to_time + (12*60*60) + rand(1..7)*60*60 }
      event_date += 7  # advance a week
    end

    team3.each do |t3|
      sporting_events << { :sport => t1[:sport], :home_team_oid => t1[:_id], :home_team_name => t1[:name],
                           :away_team_oid => t3[:_id], :away_team_name => t3[:name], :location_oid => t1[:home_field_id], 
                           :event_date => event_date.to_time + (12*60*60) + rand(1..7)*60*60 }
       event_date += 7
    end
    last_event_date = event_date  # capture date of last week of play
  end
end

# Each team plays teams in other conference once
team1 = sport_team.find({:sport => 'football'}, {:fields =>  [:sport, :name, :home_field_id, :division]})

team1.each do |t1| 
  t1_conference = t1[:division][0..2]
  team2 = sport_team.find({:sport => 'football', :division => {"$ne" => t1[:division]} }, {:fields =>  [:sport, :name, :home_field_id, :division]})
  event_date = last_event_date +7     # start the week following the last week of play
  home_field_id = t1[:home_field_id]  # first game is at t1's home field

  team2.each do |t2| 
    t2_conference = t2[:division][0..2]
    if t1_conference == t2_conference

      sporting_events << { :sport => t1[:sport], :home_team_oid => t1[:_id], :home_team_name => t1[:name],
                           :away_team_oid => t2[:_id], :away_team_name => t2[:name], :location_oid => home_field_id,
                           :event_date => event_date.to_time + (12*60*60) + rand(1..7)*60*60 }

      home_field_id = (t1[:home_field_id] == home_field_id) ? t2[:home_field_id] : t1[:home_field_id]    # switch home field each week

      event_date += 7
    end
  end
end

# generate two "random pre-season games

# start on first sunday in september
event_date = Date.new(Date.today.year,9,1)
until event_date.sunday? do
  event_date += 1
end
event_date -= 7   # set event date to previouse sunday (sunday before 9,1)

next_home_teams = [] # we'll collect home and away teams so each can have one home game
next_away_teams = []

t1 = t2 = nil
teams = sport_team.find({:sport => 'football' }, {:fields =>  [:sport, :name, :home_field_id]}).sort({_id: 1}).each do |t|
 
  unless t1
    t1 = t
    next
  end

  t2 = t 

  sporting_events << { :sport => t1[:sport], :home_team_oid => t1[:_id], :home_team_name => t1[:name],
                       :away_team_oid => t2[:_id], :away_team_name => t2[:name], :location_oid => t1[:home_field_id],
                       :event_date => event_date.to_time + (12*60*60) + rand(1..7)*60*60 }
  next_home_teams << t2
  next_away_teams << t1
 
  t1 = t2 = nil
end

event_date -=7  # Set event date back a week

next_home_teams.reverse.each do |t1| 
  t2 = next_away_teams[next_home_teams.index(t1)]

  sporting_events << { :sport => t1[:sport], :home_team_oid => t1[:_id], :home_team_name => t1[:name],
                       :away_team_oid => t2[:_id], :away_team_name => t2[:name], :location_oid => t1[:home_field_id],
                       :event_date => event_date.to_time + (12*60*60) + rand(1..7)*60*60 }
end

result = sporting_event.insert_many(sporting_events)
puts "inserted: " + result.inserted_count.to_s + " sporting events"

