#!/usr/bin/env ruby

require 'rubygems'  # not necessary for Ruby 1.9
require 'mongo'

# Connect to db. Located here to make it easy to change port etc...
db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'dms_sample')

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


