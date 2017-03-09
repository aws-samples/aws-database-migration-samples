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
Mongo::Logger.logger       = ::Logger.new('./log/generate_tickets.log')
Mongo::Logger.logger.level = ::Logger::INFO

sporting_event_ticket = db[:sporting_event_ticket]
result = sporting_event_ticket.drop()

sport_location = db[:sport_location]
sporting_event = db[:sporting_event]

# load tickets for each sporting event
sporting_event.find().each do |event|
  puts "************ Loading Tickets For New Event ************"

  standard_price = (( 50 - 30)*rand() + 30 ).round(2)

  # get the location so we can include a pointer to it
  event_loc = sport_location.find({:_id => event[:location_oid]}).first

  tickets = []  # to collect the tickets

    event_loc[:seats].each_pair do |k,v|
      case k.to_s
        when 'luxury'
          price = (3*standard_price).round(2)
          v.each do |ticket|
            t_pieces = ticket.split('.')
            tickets << {:event_oid => event[:_id], :event_location_oid => event_loc[:_id], :seat_quality => 'luxury', :price => price , 
                        :level => t_pieces[0], :section =>t_pieces[1], :row => t_pieces[2], :seat => t_pieces[3], :number => ticket}
          end
        when 'premium'
          price = (2*standard_price).round(2)
          v.each do |ticket|
            t_pieces = ticket.split('.')
            tickets << {:event_oid => event[:_id], :event_location_oid => event_loc[:_id], :seat_quality => 'premium', :price => price , 
                        :level => t_pieces[0], :section =>t_pieces[1], :row => t_pieces[2], :seat => t_pieces[3], :number => ticket}
          end
        when 'standard'
          price = standard_price.round(2)
          v.each do |ticket|
            t_pieces = ticket.split('.')
            tickets << {:event_oid => event[:_id], :event_location_oid => event_loc[:_id], :seat_quality => 'standard', :price => price , 
                        :level => t_pieces[0], :section =>t_pieces[1], :row => t_pieces[2], :seat => t_pieces[3], :number => ticket}
          end
        when 'subStandard'
          price = (0.75*standard_price).round(2)
          v.each do |ticket|
            t_pieces = ticket.split('.')
            tickets << {:event_oid => event[:_id], :event_location_oid => event_loc[:_id], :seat_quality => 'subStandard', :price => price , 
                        :level => t_pieces[0], :section =>t_pieces[1], :row => t_pieces[2], :seat => t_pieces[3], :number => ticket}
          end
        when 'obstructed'
          price = (0.5*standard_price).round(2)
          v.each do |ticket|
            t_pieces = ticket.split('.')
            tickets << {:event_oid => event[:_id], :event_location_oid => event_loc[:_id], :seat_quality => 'obstructed', :price => price , 
                        :level => t_pieces[0], :section =>t_pieces[1], :row => t_pieces[2], :seat => t_pieces[3], :number => ticket}
          end
      end      
    end


 result = sporting_event_ticket.insert_many(tickets)
 puts "inserted: " + result.inserted_count.to_s + " tickets"

 puts "inserted tickets for: " + event[:sport] + " " + event[:home_team_name] + " VS " + event[:away_team_name] + " on  " + event[:event_date].to_s + " at " + event_loc[:name] + " total tickets: " + tickets.length.to_s

end 
