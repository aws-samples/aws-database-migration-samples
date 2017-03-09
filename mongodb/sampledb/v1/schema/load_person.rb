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
Mongo::Logger.logger       = ::Logger.new('./log/load_person.log')
Mongo::Logger.logger.level = ::Logger::INFO

person = db[:person]
person.drop()

name_data = db[:name_data]
names = name_data.find.first
male_firsts = names[:MALE_FIRST]
female_firsts = names[:FEMALE_FIRST]
lasts = names[:LAST]

id = 0

lasts.each_slice(10) do |l_slice|
  people = [] # initialize the array

  l_slice.each do |l|
    male_firsts.each do |m|
      id += 1
      people << {:id => id, :first_name => m, :last_name => l, :full_name => m + " " + l}
    end

    female_firsts.each do |f|
      id += 1
      people << {:id => id, :first_name => f, :last_name => l, :full_name => f + " " + l}
    end
  end

  # Insert the array after shuffleing the names around
  result = person.insert_many(people.shuffle)
  puts "inserted: " + result.inserted_count.to_s + " people"
end


