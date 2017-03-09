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
Mongo::Logger.logger       = ::Logger.new('./log/load_sports_teams.log')
Mongo::Logger.logger.level = ::Logger::INFO

# Load and reset Mongo collection
sport_team = db[:sport_team]
result = sport_team.drop


####################################################################
#
# First load NFL teams
####################################################################

# Team hash for assigning the team name from the abbreviation
team_hash = {:LA =>['Los Angeles Rams','NFC West'],
:NYG =>['New York Giants','NFC East'],
:NYJ =>['New York Jets','AFC East'],
:WAS =>['Washington Redskins','NFC East'],
:GB =>['Green Bay Packers','NFC North'],
:DAL =>['Dallas Cowboys','NFC East'],
:KC =>['Kansas City Chiefs','AFC West'],
:DEN =>['Denver Broncos','AFC West'],
:CAR =>['Carolina Panthers','NFC South'],
:NO =>['New Orleans Saints','NFC South'],
:HOU =>['Houston Texans','AFC South'],
:BUF =>['Buffalo Bills','AFC East'],
:ATL =>['Atlanta Falcons','NFC South'],
:BAL =>['Baltimore Ravens','AFC North'],
:SD =>['San Diego Chargers','AFC West'],
:PHI =>['Philadelphia Eagles','NFC East'],
:TEN =>['Tennessee Titans','AFC South'],
:SF =>['San Francisco 49ers','NFC West'],
:PIT =>['Pittsburgh Steelers','AFC North'],
:SEA =>['Seattle Seahawks','NFC West'],
:CLE =>['Cleveland Browns','AFC North'],
:JAX =>['Jacksonville Jaguars','AFC South'],
:IND =>['Indianapolis Colts','AFC South'],
:NE =>['New England Patriots','AFC East'],
:MIN =>['Minnesota Vikings','NFC North'],
:TB =>['Tampa Bay Buccaneers','NFC South'],
:CIN =>['Cincinnati Bengals','AFC North'],
:MIA =>['Miami Dolphins','AFC East'],
:DET =>['Detroit Lions','NFC North'],
:ARI =>['Arizona Cardinals','NFC West'],
:CHI =>['Chicago Bears','NFC North'],
:OAK =>['Oakland Raiders','AFC West']}


nfl_team = {}

nfl_data = db[:nfl_data]

nfl_data.find.each do |player|
  # use the player team to de-dup team data fro mthe player data
  hkey = player[:team].to_sym

  unless nfl_team.key?(hkey)
    stadium_data = db[:nfl_stadium_data]
    sport_data = db[:sport]
    sport = sport_data.find({ :name => 'football' }).first
    stadium = stadium_data.find({ :team => team_hash[hkey][0] }).first
    sport_loc = db[:sport_location]
    home_field = sport_loc.find({ :id => stadium[:sport_location_id]}).first

    nfl_team[hkey] = {:sport_oid => sport[:_id], :sport => 'football', :name => team_hash[hkey][0], :short_name => player[:team], 
                      :division => team_hash[hkey][1], :home_field => home_field[:name], :home_field_id => home_field[:_id], 
                      :players => [] } 
  end

  stats = []
  unless player[:stat1_val] == '--' || player[:stat1] == 'null'
    stats << {player[:stat1] => player[:stat1_val]}
  end
  unless player[:stat2_val] == '--' || player[:stat2] == 'null'
    stats << {player[:stat2] => player[:stat2_val]}
  end
  unless player[:stat3_val] == '--' || player[:stat3] == 'null'
    stats << {player[:stat3] => player[:stat3_val]}
  end
  unless player[:stat4_val] == '--' || player[:stat4] == 'null'
    stats << {player[:stat4] => player[:stat4_val]}
  end

  nfl_team[hkey][:players] << {:name => player[:name], :number => player[:player_number], :position => player[:position], :status => player[:status],:stats => stats }
end

teams = []
nfl_team.each_key do |k|
  teams << nfl_team[k]
end

# Load Mongo collection
result = sport_team.insert_many(teams)
puts "inserted: " + result.inserted_count.to_s + " NFL teams"


####################################################################
#
# Then load MLB teams
####################################################################
# map of team names to location_ids

mlb_stadium_map = {'Arizona Diamondbacks' => 4,
                   'Atlanta Braves' => 27, 
                   'Baltimore Orioles' => 19, 
                   'Boston Red Sox' => 10, 
                   'Chicago Cubs' => 29, 
                   'Chicago White Sox' => 28, 
                   'Cincinnati Reds' => 12, 
                   'Cleveland Indians' => 22, 
                   'Colorado Rockies' => 8, 
                   'Detroit Tigers' => 7, 
                   'Houston Astros' => 16, 
                   'Kansas City Royals' => 13, 
                   'Los Angeles Angels' => 1, 
                   'Los Angeles Dodgers' => 9, 
                   'Miami Marlins' => 14, 
                   'Milwaukee Brewers' => 15, 
                   'Minnesota Twins' => 25, 
                   'New York Mets' => 5, 
                   'New York Yankees' => 30, 
                   'Oakland Athletics' => 18, 
                   'Philadelphia Phillies' => 6, 
                   'Pittsburgh Pirates' => 21, 
                   'San Diego Padres' => 20, 
                   'San Francisco Giants' => 2, 
                   'Seattle Mariners' => 24, 
                   'St. Louis Cardinals' => 3, 
                   'Tampa Bay Rays' => 26, 
                   'Texas Rangers' => 11, 
                   'Toronto Blue Jays' => 23, 
                   'Washington Nationals' => 17} 

mlb_team = {}

mlb_data = db[:mlb_data]

mlb_data.find.each do |player|
    # use mlb_team to de-dup team data from the player data
    hkey = player[:mlb_team].to_sym

    unless mlb_team.key?(hkey)
      loc_id = mlb_stadium_map[player[:mlb_team_long]]
      loc_data = db[:sport_location]
      sport_data = db[:sport]
      sport = sport_data.find({ :name => 'baseball' }).first
      home_field = loc_data.find({ :id => loc_id }).first

      case player[:mlb_team]
        when 'BAL', 'BOS', 'TOR', 'TB', 'NYY'
          sport_div = 'AL East'
        when 'CLE','DET','KC','CWS','MIN'
          sport_div = 'AL Central'
        when 'TEX','SEA','HOU','OAK','LAA'
          sport_div = 'AL West'
        when 'WSH','MIA','NYM','PHI','ATL'
          sport_div = 'NL East'
        when 'CHC','STL','PIT','MIL','CIN'
          sport_div = 'NL Central'
        when 'COL','SD','LAD','SF','ARI'
          sport_div = 'NL West'
      end

      mlb_team[hkey] = {:sport_oid => sport[:_id], :sport => 'baseball', :name => player[:mlb_team_long], :short_name => player[:mlb_team], 
                        :division => sport_div, :home_field => home_field[:name], :home_field_id => home_field[:_id], 
                        :players => [] } 
    end



    mlb_team[hkey][:players] << {:name => player[:mlb_name], :position => player[:mlb_pos], :bats => player[:bats], :throws => player[:throws], 
                                 :birth_year => player[:birth_year], :debut => player[:debut], :depth => [:mlb_depth] }
end


teams = []
mlb_team.each_key do |k|
  teams << mlb_team[k]
end


# Load Mongo collection
result = sport_team.insert_many(teams)
puts "inserted: " + result.inserted_count.to_s + " MLB teams"



