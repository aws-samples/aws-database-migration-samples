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


mkdir ./log
./schema/load_mlb_data.rb
./schema/load_nfl_data.rb
./schema/load_name_data.rb
./schema/load_nfl_stadium_data.rb
./schema/load_sport.rb
./schema/load_sport_location.rb
./schema/load_sports_teams.rb
./schema/generate_sporting_events.rb
./schema/generate_tickets.rb
./schema/load_person.rb
