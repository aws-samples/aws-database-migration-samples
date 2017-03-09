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
Mongo::Logger.logger       = ::Logger.new('./log/load_sport_location.log')
Mongo::Logger.logger.level = ::Logger::INFO

sport_locations = []

###################################
# map of ids to baseball stadiums #
###################################
bb_stadiums = [[1,'Angel Stadium','Anaheim California',45483],
               [2,'AT&T Park','San Francisco California',41915],
               [3,'Busch Stadium','St Louis Missouri',43975],
               [4,'Chase Field','Phoenix Arizona',48519],
               [5,'Citi Field','Queens New York',41922],
               [6,'Citizens Bank Park','Philadelphia Pennsylvania',43651],
               [7,'Comercia Park','Detroit Michigan',41297],
               [8,'Coors Field','Denver Colorado',50398],
               [9,'Dodger Stadium','Los Angeles California',56000],
               [10,'Fenway Park','Boston Massachusetts',37949],
               [11,'GLobe Life Park','Arlington Texas',48114],
               [12,'Great American Ball Park','Cincinnati Ohio',42319],
               [13,'Kauffman Stadium','Kansas City Missouri',37903],
               [14,'Martins Park','Miami Florida',36742],
               [15,'Miller Park','Milwaukee Wisconsin',41900],
               [16,'Minute Maid Park','Houston Texas',41676],
               [17,'Nationals Park','Washington D.C.',41313],
               [18,'Oakland Coliseum','Oakland California',35067],
               [19,'Camden Yards','Baltimore Maryland',45971],
               [20,'Petco Park','San Diego California',40162],
               [21,'PNC Park','Pittsburgh Pennsylvania',38362],
               [22,'Progressive Field','Cleveland Ohio',35225],
               [23,'Rogers Centre','Toronto Ontario',49282],
               [24,'Safeco Field','Seattle Washington',47963],
               [25,'Target Field','Minneapolis Minnesota',38871],
               [26,'Tropicana Field','St. Petersburg Florida',31042],
               [27,'Turner Field','Atlanta Georgia',49586],
               [28,'US Cellular Field','Chicago Illinois',40615],
               [29,'Wrigley Field','Chicago Illinois',41268],
               [30,'Yankee Stadium','Bronx New York',49642]]
               
####################################
# Procedure to generate seats
####################################
def generate_seats(capacity, levels, sections)
  seats = {:luxury => [], :premium => [], :standard => [], :subStandard => [], :obstructed => []}

  tot_seats = 0;
  min_rows = 15    # minimum rows per section
  max_rows = 25    # maximum rows per section

  (1..levels).each do |i|
    (1..sections).each do |j|

      rows = rand(min_rows..max_rows)
      seats_in_row = capacity/(levels*sections*rows) + 1

      (1..rows).each do |r|
        (1..seats_in_row).each do |s|

          tot_seats += 1

          case rand(1..100)
          when 1..5
            seat_type = 'luxury'        # 5% luxury seats
          when 6..35
            seat_type = 'premium'       # 30% premium seats
          when 36..89
            seat_type = 'standard'      # 54% standard seats
          when 90..99
            seat_type = 'subStandard'  # 10% sub-standard seats
          when 100
            seat_type = 'obstructed'    # 1% obstructed seats
          end

          row = 'abcdefghijklmnopqrstuvwxyz'[r]

          seat = i.to_s + '.' + j.to_s + '.' + row.to_s + '.' + s.to_s

          seats[seat_type.to_sym] << seat

        end
      end
    end
  end
  seats
end


puts "***** Loading Baseball Stadium Data *****"
bb_stadiums.each do |s|
  capacity = s[3].to_i
  levels   = capacity < 50000 ? 2 : 3
  sections = (capacity/1000).round
 
  puts "** Loading: " + s[1] + "   Seats: " + capacity.to_s

  seats = generate_seats(capacity, levels, sections)
  sport_location = {:id => s[0], :name => s[1], :city => s[2], :seating_capacity => capacity, :levels => levels, :sections => sections,:seats => seats }
  sport_locations << sport_location
end


puts "***** Loading Football Stadium Data *****"
nfl_stadium_data = db[:nfl_stadium_data]
nfl_stadium_data.find.each do |s|
  capacity = s[:seating_capacity].to_i
  levels   = capacity < 75000 ? 2 : 3
  sections = (capacity/1000).round
  
  puts "** Loading: " + s[:stadium] + "   Seats: " + capacity.to_s

  seats = generate_seats(capacity, levels, sections)
  sport_location = {:id => s[:sport_location_id], :name => s[:stadium], :city => s[:location], :seating_capacity => capacity, 
                    :levels => levels, :sections => sections, :seats => seats }
  sport_locations << sport_location
end

# Load Mongo collection
sport_loc = db[:sport_location]
result = sport_loc.drop
sport_locations.each do |l|
  puts "Loading: " + l[:name] + " capacity: " + l[:seating_capacity].to_s
  sl = [l]
  result = sport_loc.insert_many(sl)
  puts "inserted: " + result.inserted_count.to_s + " sport location records"
end
#result = sport_loc.insert_many(sport_locations)
#puts "inserted: " + result.inserted_count.to_s + " sport location records"
