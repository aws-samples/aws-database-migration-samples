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

create or replace view sporting_event_ticket_info as
select t.id as ticket_id
      ,e.event_id
      ,e.sport
      ,e.event_date_time
      ,e.home_team
      ,e.away_team
      ,e.location
      ,e.city
      ,t.seat_level
      ,t.seat_section
      ,t.seat_row
      ,t.seat
      ,t.ticket_price
      ,p.full_name as ticketholder
from sporting_event_info e
   , sporting_event_ticket t
   , person p
where t.sporting_event_id = e.event_id
and   t.ticketholder_id = p.id (+)
/
