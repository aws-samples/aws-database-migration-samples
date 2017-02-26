#!/usr/bin/env ruby

require 'rubygems'  # not necessary for Ruby 1.9
require 'mongo'

# Connect to db. Located here to make it easy to change port etc...
db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'dms_sample')

sport_team = db[:sport_team]

sport_team.find.each do |t|
  t.each_key do |k|
    puts k + " => " + t[k].to_s
  end
end
