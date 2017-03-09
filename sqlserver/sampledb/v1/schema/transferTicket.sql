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


create procedure transferTicket(@ticket_id BIGINT, @new_ticketholder_id BIGINT, @transfer_all BIT = 0, @price SMALLMONEY) as
BEGIN TRY
  DECLARE @last_txn_date DATETIME;
  DECLARE @old_ticketholder_id INT;
  DECLARE @sporting_event_ticket_id BIGINT;
  DECLARE @purchase_price SMALLMONEY;

  -- get the latest record of purchase for this particular tickeholder for that event
  -- note they could have purchsed, sold and repurchased the ticket
  SELECT @last_txn_date = max(h.transaction_date_time), 
         @old_ticketholder_id = t.ticketholder_id
  FROM   ticket_purchase_hist h
        ,sporting_event_ticket t
  WHERE  t.id = @ticket_id
  AND    h.purchased_by_id = t.ticketholder_id
  GROUP BY t.ticketholder_id;

  -- get all tickets purchased at the same time for that event by that ticketholder
  DECLARE @xfer_cur CURSOR;
  SET @xfer_cur = CURSOR FOR
  SELECT sporting_event_ticket_id, purchase_price 
  FROM ticket_purchase_hist
  WHERE  purchased_by_id = @old_ticketholder_id
  AND    transaction_date_time = @last_txn_date
  AND    ((sporting_event_ticket_id = @ticket_id) OR (@transfer_all = 1) );

  OPEN @xfer_cur;
  FETCH @xfer_cur INTO @sporting_event_ticket_id, @purchase_price;

  WHILE @@FETCH_STATUS = 0
  BEGIN
	-- update the sporting event ticket with the new owner
	UPDATE sporting_event_ticket 
    SET    ticketholder_id = @new_ticketholder_id
    WHERE  id = @sporting_event_ticket_id;

	-- record the transaction
	INSERT INTO ticket_purchase_hist(sporting_event_ticket_id, purchased_by_id, transferred_from_id, transaction_date_time, purchase_price)
    VALUES(@sporting_event_ticket_id, @new_ticketholder_id, @old_ticketholder_id, current_timestamp, ISNULL(@price,@purchase_price)); 

	PRINT(CONCAT('Ticket id: ', @sporting_event_ticket_id, ' Original price: ', @purchase_price, ' Old Ticketholder: ',@old_ticketholder_id,' Txn Date: ', @last_txn_date));

    FETCH @xfer_cur INTO @sporting_event_ticket_id, @purchase_price;
  END;

  CLOSE @xfer_cur;
  DEALLOCATE @xfer_cur;
  COMMIT;
END TRY
BEGIN CATCH
END CATCH;

go
