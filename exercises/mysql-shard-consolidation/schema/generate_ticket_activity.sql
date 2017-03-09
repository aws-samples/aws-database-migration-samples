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
----------------------------------------------
-- create procedure to generate ticket activity
-----------------------------------------------
DELIMITER $$

DROP PROCEDURE IF EXISTS generateTicketActivity $$

CREATE PROCEDURE generateTicketActivity(IN p_max_transactions INT, IN p_delay_in_seconds REAL(5,2))
BEGIN
  DECLARE v_min_person_id INT;
  DECLARE v_max_person_id INT;
  DECLARE v_min_row INT;
  DECLARE v_max_row INT;
  DECLARE v_target_row INT;
  DECLARE v_event_id BIGINT;
  DECLARE v_target_person_id INT;
  DECLARE v_person_id INT;
  DECLARE v_quantity INT;
  DECLARE v_current_txn INT DEFAULT 0;
  DECLARE v_reset_events INT DEFAULT 1;
  DECLARE v_max_transactions INT;
  DECLARE v_delay_message VARCHAR(100);
  DECLARE v_delay REAL(5,2);

  SET v_delay = COALESCE(p_delay_in_seconds,0.25);

  drop temporary table if exists v_open_events;
  create temporary table v_open_events(rownum INT NOT NULL AUTO_INCREMENT, id BIGINT, constraint v_pk primary key(rownum)) engine=memory;

  /* get the range of person ids. */
  SELECT MIN(id), MAX(id) into v_min_person_id, v_max_person_id from person;

  SET v_max_transactions = COALESCE(p_max_transactions,1000);

  WHILE v_current_txn < v_max_transactions DO
    IF v_reset_events = 1 THEN
      DELETE FROM v_open_events;
      INSERT INTO v_open_events(id) SELECT distinct sporting_event_id FROM sporting_event_ticket;
      SELECT MIN(rownum), MAX(rownum) INTO v_min_row, v_max_row FROM v_open_events;
      SET v_reset_events = 0;
    END IF;

    SET v_target_row = ROUND((RAND() * (v_max_row - v_min_row)) + v_min_row);
    SELECT id INTO v_event_id FROM v_open_events WHERE rownum = v_target_row;

    SET v_target_person_id = ROUND((RAND()*(v_max_person_id - v_min_person_id)) + v_min_person_id);
    SELECT MIN(id) INTO v_person_id FROM person WHERE id > v_target_person_id -1;

    SET v_quantity = ROUND((RAND() * (6 - 1)) + 1);
 
    /* The following will sell tickets. If tickets aren't available, there should be exception processing to reload the events table.
       That processing hasn't been written yet (for the mysql examples.)
    */

    call sellTickets(v_person_id, v_event_id, v_quantity);

    SET v_current_txn = v_current_txn +1;

    SET v_delay_message = (SELECT sleep(v_delay) );

  END WHILE;
  drop temporary table if exists v_open_events;
END;
$$

DELIMITER ;
