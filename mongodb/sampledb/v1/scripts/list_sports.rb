#!/usr/bin/env ruby

require 'rubygems'  # not necessary for Ruby 1.9
require 'mongo'

# Connect to db. Located here to make it easy to change port etc...
db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'dms_sample')

sport = db[:sport]
sport.find.each do |s|
  puts s[:name] + " " + s[:league] + " " + s[:league_name]
  puts "  Divisions: "
  s[:divisions].each do |d|
    puts "    " + d[:name] + " " + d[:description]
  end
end
