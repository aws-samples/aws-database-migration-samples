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
# create procedure to transfer tickets
#######################
DELIMITER $$

DROP PROCEDURE IF EXISTS transferTicket $$


CREATE PROCEDURE transferTicket(p_ticket_id BIGINT, p_new_ticketholder_id MEDIUMINT, p_transfer_all TINYINT, p_price DECIMAL(6,2))
BEGIN 
  DECLARE v_last_txn_date DATETIME;
  DECLARE v_old_ticketholder_id MEDIUMINT;
  DECLARE v_sporting_event_ticket_id BIGINT;
  DECLARE v_purchase_price DECIMAL(6,2);
  DECLARE v_time_of_purchase TIMESTAMP;
  DECLARE all_done INT DEFAULT FALSE;

  /* get all tickets purchased at the same time for that event by that ticketholder */

  DECLARE xfer_cur CURSOR FOR
  SELECT sporting_event_ticket_id, purchase_price 
  FROM ticket_purchase_hist
  WHERE  purchased_by_id = v_old_ticketholder_id
  AND    transaction_date_time = v_last_txn_date
  AND    ((sporting_event_ticket_id = p_ticket_id) OR (p_transfer_all = TRUE) );
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET all_done = TRUE;

  /*  get the latest record of purchase for this particular tickeholder for that event
      note they could have purchsed, sold and repurchased the ticket 
  */

  SELECT max(h.transaction_date_time), t.ticketholder_id
  INTO   v_last_txn_date, v_old_ticketholder_id
  FROM   ticket_purchase_hist h
        ,sporting_event_ticket t
  WHERE  t.id = p_ticket_id
  AND    h.purchased_by_id = t.ticketholder_id
  GROUP BY t.ticketholder_id;

select p_transfer_all;

  SET v_time_of_purchase = current_timestamp();

  OPEN xfer_cur;
  xfer_loop: LOOP
    FETCH xfer_cur INTO v_sporting_event_ticket_id, v_purchase_price;

    IF all_done THEN
      CLOSE xfer_cur;
      LEAVE xfer_loop;
    END IF;

    /*  update the sporting event ticket with the new owner */
    UPDATE sporting_event_ticket 
    SET    ticketholder_id = p_new_ticketholder_id
    WHERE  id = v_sporting_event_ticket_id;

    /* record the transaction */
    INSERT INTO ticket_purchase_hist(sporting_event_ticket_id, purchased_by_id, transferred_from_id, transaction_date_time, purchase_price)
    VALUES(v_sporting_event_ticket_id, p_new_ticketholder_id, v_old_ticketholder_id, v_time_of_purchase,COALESCE( p_price,v_purchase_price)); 

    SELECT CONCAT('Ticket id: ', v_sporting_event_ticket_id, ' Original price: ', v_purchase_price, ' Old Ticketholder: ',v_old_ticketholder_id,' Txn Date: ', v_last_txn_date);

  END LOOP;
END;

$$

DELIMITER ;
