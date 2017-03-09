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
# create procedure to generate MLB tickets
#######################
DELIMITER $$

DROP PROCEDURE IF EXISTS generateSportTickets $$

create procedure generateSportTickets(IN p_sport VARCHAR(15) ) 
BEGIN
  DECLARE v_event_id BIGINT;
  DECLARE all_done INT DEFAULT FALSE;

  DECLARE event_cur CURSOR FOR
  SELECT id 
  FROM sporting_event 
  WHERE sport_type_name = p_sport;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET all_done = TRUE;

select p_sport;

  OPEN event_cur;
  event_loop: LOOP
    FETCH event_cur INTO v_event_id;

    IF all_done THEN
      CLOSE event_cur;
      LEAVE event_loop;
    END IF;

    CALL generateTickets(v_event_id);
  END LOOP;

END;
$$
DELIMITER ;

