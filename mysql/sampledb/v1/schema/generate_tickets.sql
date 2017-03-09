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


#######################
# create procedure to generate tickets
#######################
DELIMITER $$

DROP PROCEDURE IF EXISTS generateTickets $$

create procedure generateTickets(IN p_event_id BIGINT) 
BEGIN
  DECLARE v_e_id BIGINT;
  DECLARE v_loc_id   INT;
  DECLARE v_standard_price DECIMAL(6,2);
  DECLARE all_done INT DEFAULT FALSE;

  DECLARE event_cur CURSOR FOR
  SELECT id, location_id
  FROM sporting_event
  WHERE id = p_event_id;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET all_done = TRUE;


  /* randomly generated standard price between 30 and 50 dollars */
  SET v_standard_price =  ROUND((RAND() * (50-30))+30,2);

  OPEN event_cur;
  ticket_loop: LOOP

    FETCH event_cur INTO v_e_id, v_loc_id;
    IF all_done THEN
      CLOSE event_cur;
      LEAVE ticket_loop;
    END IF;
 
    INSERT INTO sporting_event_ticket(sporting_event_id,sport_location_id,seat_level,seat_section,seat_row,seat,ticket_price)
    SELECT sporting_event.id
      ,seat.sport_location_id
      ,seat.seat_level
      ,seat.seat_section
      ,seat.seat_row
      ,seat.seat
      ,(CASE 
         WHEN seat.seat_type = 'luxury' THEN 3*v_standard_price
         WHEN seat.seat_type = 'premium' THEN 2*v_standard_price
         WHEN seat.seat_type = 'standard' THEN v_standard_price
         WHEN seat.seat_type = 'sub-standard' THEN 0.8*v_standard_price
         WHEN seat.seat_type = 'obstructed' THEN 0.5*v_standard_price
         WHEN seat.seat_type = 'standing' THEN 0.5*v_standard_price
      END ) ticket_price
    FROM sporting_event
       ,seat
    WHERE sporting_event.location_id = seat.sport_location_id
    AND   sporting_event.id = v_e_id;
    
  END LOOP;

END;
$$

DELIMITER ;
