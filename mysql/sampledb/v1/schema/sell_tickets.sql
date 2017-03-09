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
# create procedure to sell tickets
#######################
DELIMITER $$

DROP PROCEDURE IF EXISTS sellTickets $$

CREATE PROCEDURE sellTickets(IN p_person_id MEDIUMINT, IN p_event_id BIGINT, IN p_quantity SMALLINT )
BEGIN
  DECLARE v_ticket_id BIGINT;
  DECLARE v_seat_level INT;
  DECLARE v_seat_section varchar(15);
  DECLARE v_seat_row varchar(10); 
  DECLARE v_tickets_sold SMALLINT DEFAULT 0;
  DECLARE v_time_of_sale DATETIME;
  DECLARE all_done INT DEFAULT FALSE;

  DECLARE t_cur CURSOR FOR 
  SELECT id, seat_level, seat_section, seat_row
  FROM   sporting_event_ticket
  WHERE  sporting_event_id = p_event_id
  ORDER BY seat_level, seat_section, seat_row;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET all_done = TRUE;

  SET v_time_of_sale = current_timestamp();

  OPEN t_cur;
  tik_loop: LOOP
    START TRANSACTION;
    FETCH t_cur INTO v_ticket_id, v_seat_level, v_seat_section, v_seat_row;

    IF all_done THEN
      CLOSE t_cur;
      ROLLBACK;
      SELECT CONCAT('Sorry, unable to find ', p_quantity,' tickets for that event.');
      LEAVE tik_loop;
    END IF;

    UPDATE sporting_event_ticket
    SET ticketholder_id = p_person_id
    WHERE id = v_ticket_id;

    INSERT INTO ticket_purchase_hist(sporting_event_ticket_id, purchased_by_id, transaction_date_time, purchase_price)
    SELECT id, ticketholder_id, v_time_of_sale,ticket_price
    FROM sporting_event_ticket
    WHERE id = v_ticket_id;

    SET v_tickets_sold = v_tickets_sold +1;

    IF v_tickets_sold = p_quantity THEN
      COMMIT;
      CLOSE t_cur;
      SELECT CONCAT('Congratulations! You''ve just purchased ',p_quantity,' tickets.');
      LEAVE tik_loop;
    END IF;
  END LOOP;
END;
$$

DELIMITER ;
