#!/usr/bin/env ruby

require 'rubygems'  # not necessary for Ruby 1.9
require 'mongo'

# Connect to db. Located here to make it easy to change port etc...
db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'dms_sample')

sport_location = db[:sport_location]

tot_locations = 0
sport_location.find.each do |t|
  tot_locations += 1
  t.each_key do |k|
    unless k == 'seats'
      puts k + " => " + t[k].to_s
    end
  end
end

puts "Total Locations: " + tot_locations.to_s
