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


create or replace procedure generate_tickets(P_event_id IN NUMBER) as
  CURSOR event_cur(P_ID NUMBER) IS
  SELECT id,location_id 
  FROM   sporting_event
  WHERE  ID = P_ID;

  standard_price NUMBER(6,2);

BEGIN
  standard_price := DBMS_RANDOM.VALUE(30,50);

  FOR event_rec IN event_cur(P_event_id) LOOP
    INSERT /*+ APPEND */ INTO sporting_event_ticket(id,sporting_event_id,sport_location_id,seat_level,seat_section,seat_row,seat,ticket_price)
    SELECT sporting_event_ticket_seq.nextval
      ,sporting_event.id
      ,seat.sport_location_id
      ,seat.seat_level
      ,seat.seat_section
      ,seat.seat_row
      ,seat.seat
      ,(CASE 
         WHEN seat.seat_type = 'luxury' THEN 3*standard_price
         WHEN seat.seat_type = 'premium' THEN 2*standard_price
         WHEN seat.seat_type = 'standard' THEN standard_price
         WHEN seat.seat_type = 'sub-standard' THEN 0.8*standard_price
         WHEN seat.seat_type = 'obstructed' THEN 0.5*standard_price
         WHEN seat.seat_type = 'standing' THEN 0.5*standard_price
      END ) ticket_price
    FROM sporting_event
       ,seat
    WHERE sporting_event.location_id = seat.sport_location_id
    AND   sporting_event.id = event_rec.id;
  END LOOP;
END;
/
