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



drop view if exists sporting_event_info;

create view sporting_event_info as 
select e.id as event_id
     , e.sport_type_name sport
     , e.start_date_time event_date_time
     , h.name home_team
     , a.name away_team
     , l.name location
     , l.city city
from sporting_event e, sport_team h, sport_team a, sport_location l
where e.home_team_id = h.id
and e.away_team_id = a.id
and e.location_id = l.id;
