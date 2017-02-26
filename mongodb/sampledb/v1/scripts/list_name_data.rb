#!/usr/bin/env ruby

require 'rubygems'  # not necessary for Ruby 1.9
require 'mongo'

# Connect to db. Located here to make it easy to change port etc...
db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'dms_sample')

name_data = db[:name_data]
names = name_data.find.first

names.keys.each do |k|
  puts k + ":"
  puts names[k]
end
