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
Mongo::Logger.logger       = ::Logger.new('./log/load_nfl_data.log')
Mongo::Logger.logger.level = ::Logger::INFO

# Load data from the file
fname = ARGV.first || './data/nfl_data.sql'

puts "loading NFL data from: " + fname

cols = []
vals = []
players = []

File.open(fname).each_with_index do |r,idx|

  # Get the attributes
  if idx == 0
    col_list = r.slice(0, r.rindex(') values ('))   # remove insert statement 
    col_list.slice!('Insert into nfl_data (')
    cols = col_list.split(',').map{ |c| c.to_sym }
  end

  # Get the values
  unless r.chomp.empty?
    r =  r.slice(r.rindex('values (') +8, r.length).strip.chomp(');')  
    r =  r.sub(/'/,'').gsub(/','/,'~').gsub(/,'/,'~').gsub(/',/,'~').gsub(/,null/,'~null').chomp("'")

    vals = r.split("~")

    player = {}
    cols.each_with_index do |c,i|
      player[c] = vals[i] 
    end

    # reformat player name
    player[:name] = player[:name].split(',')[1] + " " + player[:name].split(',')[0]
    player[:name] = player[:name].strip
    players << player   # Add to hash
  end
end

# Load Mongo collection
nfl_data = db[:nfl_data]
result = nfl_data.drop
result = nfl_data.insert_many(players)
puts "inserted: " + result.inserted_count.to_s + " nfl player records"
