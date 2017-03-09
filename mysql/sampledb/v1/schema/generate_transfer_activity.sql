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
# create procedure to generate ticket activity
#######################
DELIMITER $$

DROP PROCEDURE IF EXISTS generateTransferActivity $$

CREATE PROCEDURE generateTransferActivity(p_max_transactions INT, p_delay_in_seconds DECIMAL(5,2)) 
BEGIN
  DECLARE v_txn_count INT DEFAULT 0;
  DECLARE v_min_tik_id BIGINT;
  DECLARE v_max_tik_id BIGINT;
  DECLARE v_tik_id BIGINT;
  DECLARE v_max_p_id INT;
  DECLARE v_min_p_id INT;
  DECLARE v_person_id INT;
  DECLARE v_rand_p_max INT;
  DECLARE v_rand_max BIGINT;
  DECLARE v_xfer_all TINYINT DEFAULT 1;
  DECLARE v_price DECIMAL(6,2);
  DECLARE v_price_multiplier DECIMAL(4,2) DEFAULT 1.0;
  DECLARE v_max_transactions INT;
  DECLARE v_delay_message VARCHAR(100);
  DECLARE v_delay REAL(5,2);

  SET v_delay = COALESCE(p_delay_in_seconds,0.25);

  /* get max and min ticket ids  */
  SELECT min(sporting_event_ticket_id), max(sporting_event_ticket_id) INTO v_min_tik_id, v_max_tik_id FROM ticket_purchase_hist;

  /* get max and min person ids */
  SELECT min(id), max(id) INTO v_min_p_id, v_max_p_id FROM person;

  select concat('max t: ',v_max_tik_id,' min t: ', v_min_tik_id, 'max p: ',v_max_p_id,' min p: ', v_min_p_id);

  SET v_max_transactions = COALESCE(p_max_transactions,10);

  WHILE v_txn_count < v_max_transactions DO
    /* find a random upper bound for ticket and person ids */
    SET v_rand_max = ROUND((RAND() * (v_max_tik_id - v_min_tik_id)) + v_min_tik_id);
    SET v_rand_p_max = ROUND((RAND() * (v_max_p_id - v_min_p_id)) + v_min_p_id);

    SELECT  MAX(sporting_event_ticket_id) INTO v_tik_id
    FROM ticket_purchase_hist
    WHERE sporting_event_ticket_id <= v_rand_max;

    SELECT MAX(id) INTO v_person_id FROM person WHERE id <= v_rand_p_max;

    /* 80% of the time transfer all tickets, 20% of the time don't */

    IF ( ROUND((RAND() *(5-1)) +1 ) = 5 ) THEN
      SET v_xfer_all = 0;
    END IF;

    /* 30% of the time change the price by up to 20% in either direction */
    IF ( ROUND((RAND() * (3-1) +1)) = 1) THEN
      SET v_price_multiplier = ROUND((RAND()*(12-8)) +8)/10;
    END IF;

    SELECT v_price_multiplier*ticket_price INTO v_price 
    FROM   sporting_event_ticket
    WHERE  id = v_tik_id;

    select CONCAT('Ticket to transfer: ', v_tik_id, ' Transfer to person id: ' , v_person_id, ' All tickets?: ',v_xfer_all, ' price: ', v_price);

    call transferTicket(v_tik_id, v_person_id, v_xfer_all, v_price);

    /* reset some variables */
    SET v_txn_count = v_txn_count + 1;
    SET v_xfer_all = 1;
    SET v_price_multiplier = 1;
    SET v_delay_message = (SELECT sleep(v_delay) );

  END WHILE;
END;
$$

DELIMITER ;
 
