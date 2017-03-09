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


create procedure generateTransferActivity(@max_transactions INT) as
BEGIN TRY
  DECLARE @txn_count INT = 0;
  DECLARE @min_tik_id BIGINT;
  DECLARE @max_tik_id BIGINT;
  DECLARE @tik_id BIGINT;
  DECLARE @max_p_id INT;
  DECLARE @min_p_id INT;
  DECLARE @person_id INT;
  DECLARE @rand_p_max INT
  DECLARE @rand_max BIGINT;
  DECLARE @xfer_all BIT = 1;
  DECLARE @price SMALLMONEY;
  DECLARE @price_multiplier DECIMAL = 1;

  -- get max and min ticket ids  
  SELECT @min_tik_id = min(sporting_event_ticket_id)
	    ,@max_tik_id = max(sporting_event_ticket_id)
  FROM ticket_purchase_hist;

  -- get max and min person ids
  SELECT @min_p_id = min(id), @max_p_id = max(id) FROM person;

  print(concat('max t: ',@max_tik_id,' min t: ', @min_tik_id, 'max p: ',@max_p_id,' min p: ', @min_p_id));

  WHILE @txn_count < @max_transactions
  BEGIN
    -- find a random upper bound for ticket and person ids
	SET @rand_max = dbo.rand_int(@min_tik_id, @max_tik_id);
	SET @rand_p_max = dbo.rand_int(@min_p_id, @max_p_id);

    SELECT @tik_id = MAX(sporting_event_ticket_id)
	FROM ticket_purchase_hist
	WHERE sporting_event_ticket_id <= @rand_max;

	SELECT @person_id = MAX(id) FROM person WHERE id <= @rand_p_max;

	-- 80% of the time transfer all tickets, 20% of the time don't
	IF (dbo.rand_int(1,5) = 5 )
	  SET @xfer_all = 0;

    -- 30% of the time change the price by up to 20% in either direction
    IF (dbo.rand_int(1,3) = 1)
	  SET @price_multiplier = CAST(dbo.rand_int(8,12) as DECIMAL)/10;

	SELECT @price = @price_multiplier*ticket_price
    FROM   sporting_event_ticket
    WHERE  id = @tik_id;

 	PRINT(CONCAT('Ticket to transfer: ', @tik_id, ' Transfer to person id: ' , @person_id, ' All tickets?: ',@xfer_all, ' price: ', @price));

    exec dbo.transferTicket @tik_id, @person_id, @xfer_all, @price ;


	-- reset some variables
    SET @txn_count = @txn_count + 1;
	SET @xfer_all = 1;
	SET @price_multiplier = 1;


  END;
END TRY
BEGIN CATCH
  PRINT('Sorry, not tickets are available for transfer.');
END CATCH;

go

 
