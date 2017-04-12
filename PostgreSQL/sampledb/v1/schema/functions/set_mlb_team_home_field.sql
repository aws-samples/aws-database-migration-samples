/*
 Copyright 2017 Amazon.com

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

--- Must be run after teams are created and after sporting locations are created
---------------------------------
-- Baseball Teams
---------------------------------


-- Arizona Diamondbacks
update sport_team set home_field_id = 4  where name = 'Arizona Diamondbacks' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Atlanta Braves
update sport_team set home_field_id = 27 where name = 'Atlanta Braves' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Baltimore Orioles
update sport_team set home_field_id = 19 where name = 'Baltimore Orioles' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Boston Red Sox
update sport_team set home_field_id = 10 where name = 'Boston Red Sox' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Chicago Cubs
update sport_team set home_field_id = 29 where name = 'Chicago Cubs' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Chicago White Sox
update sport_team set home_field_id = 28 where name = 'Chicago White Sox' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Cincinnati Reds
update sport_team set home_field_id = 12 where name = 'Cincinnati Reds' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Cleveland Indians
update sport_team set home_field_id = 22 where name = 'Cleveland Indians' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Colorado Rockies
update sport_team set home_field_id = 8 where name = 'Colorado Rockies' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Detroit Tigers
update sport_team set home_field_id = 7 where name = 'Detroit Tigers' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Houston Astros
update sport_team set home_field_id = 16 where name = 'Houston Astros' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Kansas City Royals
update sport_team set home_field_id = 13 where name = 'Kansas City Royals' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Los Angeles Angels
update sport_team set home_field_id = 1 where name = 'Los Angeles Angels' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Los Angeles Dodgers
update sport_team set home_field_id = 9 where name = 'Los Angeles Dodgers' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Miami Marlins
update sport_team set home_field_id = 14 where name = 'Miami Marlins' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Milwaukee Brewers
update sport_team set home_field_id = 15 where name = 'Milwaukee Brewers' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Minnesota Twins
update sport_team set home_field_id = 25 where name = 'Minnesota Twins' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- New York Mets
update sport_team set home_field_id = 5 where name = 'New York Mets' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- New York Yankees
update sport_team set home_field_id = 30 where name = 'New York Yankees' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Oakland Athletics
update sport_team set home_field_id = 18 where name = 'Oakland Athletics' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Philadelphia Phillies
update sport_team set home_field_id = 6 where name = 'Philadelphia Phillies' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Pittsburgh Pirates
update sport_team set home_field_id = 21 where name = 'Pittsburgh Pirates' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- San Diego Padres
update sport_team set home_field_id = 20 where name = 'San Diego Padres' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- San Francisco Giants
update sport_team set home_field_id = 2 where name = 'San Francisco Giants' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Seattle Mariners
update sport_team set home_field_id = 24 where name = 'Seattle Mariners' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- St. Louis Cardinals
update sport_team set home_field_id = 3 where name = 'St. Louis Cardinals' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Tampa Bay Rays
update sport_team set home_field_id = 26 where name = 'Tampa Bay Rays' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Texas Rangers
update sport_team set home_field_id = 11 where name = 'Texas Rangers' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Toronto Blue Jays
update sport_team set home_field_id = 23 where name = 'Toronto Blue Jays' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';

-- Washington Nationals
update sport_team set home_field_id = 17 where name = 'Washington Nationals' and sport_type_name = 'baseball' and sport_league_short_name = 'MLB';



