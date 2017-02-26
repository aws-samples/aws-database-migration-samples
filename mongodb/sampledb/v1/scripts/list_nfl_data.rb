#!/usr/bin/env ruby

require 'rubygems'  # not necessary for Ruby 1.9
require 'mongo'

# Connect to db. Located here to make it easy to change port etc...
db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'dms_sample')

nfl_data = db[:nfl_data]
nfl_data.find.each do |player|
  player.each_key do |k|
    puts k + " => " + player[k]
  end
end
