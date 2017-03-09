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


create procedure sellTickets(@person_id INT, @event_id BIGINT, @quantity INT = 1) as
BEGIN TRY
  DECLARE @seat_level INT;
  DECLARE @seat_section varchar(15);
  DECLARE @seat_row varchar(10); 
  DECLARE @seats_available INT = 0;
  DECLARE @success INT = 0;
  DECLARE @rows_updated INT = 0;
  DECLARE @ticket_ids TABLE (id BIGINT, price smallmoney);

  WHILE @success <> 1
  BEGIN
    SET @seats_available = 0;

    -- select a row with enough sid-by-side seats
    SELECT TOP(1) @seats_available = count(*), @seat_level = seat_level,@seat_section = seat_section, @seat_row = seat_row 
    FROM sporting_event_ticket 
    WHERE sporting_event_id = @event_id
	AND TICKETHOLDER_ID IS NULL
    GROUP BY seat_level,seat_section,seat_row 
    HAVING COUNT(*) >= @quantity;

    IF @seats_available < 1 
	  BEGIN
	    SELECT @seats_available = count(*) FROM sporting_event_ticket WHERE sporting_event_id = @event_id and ticketholder_id IS NULL;
		IF @seats_available = 0 
		  UPDATE sporting_event SET sold_out = 1 WHERE id = @event_id;
        RAISERROR ('ERROR: Unable to find %d adjacent seats. Try allowing singlets...', 11, 1, @quantity);
	  END;

	BEGIN TRANSACTION
      UPDATE sporting_event_ticket
      SET ticketholder_id = @person_id
	  OUTPUT INSERTED.id, INSERTED.ticket_price INTO @ticket_ids
      WHERE id IN (
        SELECT TOP(@quantity) ID FROM sporting_event_ticket 
        WHERE sporting_event_id = @event_id
        AND seat_level = @seat_level
        AND seat_section = @seat_section
        AND seat_row = @seat_row
		AND ticketholder_id IS NULL
        ORDER BY seat_level,seat_section,seat_row);

		SET @rows_updated = @@ROWCOUNT;

      IF @rows_updated = @quantity
	    BEGIN
		  --- record the purchase in the history table
		  INSERT INTO ticket_purchase_hist(sporting_event_ticket_id, purchased_by_id, transaction_date_time, purchase_price)
		  SELECT id,@person_id, current_timestamp, price
		  FROM @ticket_ids;
		  DELETE FROM @ticket_ids;

		  PRINT(CONCAT('Sold ',@rows_updated,' seats - level: ',@seat_level,' section: ',@seat_section,' row: ',@seat_row));

   	      SET @success = 1;
		  COMMIT;
		END;
	  ELSE
		ROLLBACK;   
  END;
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);  
    DECLARE @ErrorSeverity INT;  
    DECLARE @ErrorState INT;  
  
    SELECT   
        @ErrorMessage = ERROR_MESSAGE(),  
        @ErrorSeverity = ERROR_SEVERITY(),  
        @ErrorState = ERROR_STATE();  
  
    -- Use RAISERROR inside the CATCH block to return error  
    -- information about the original error that caused  
    -- execution to jump to the CATCH block.  
    RAISERROR (@ErrorMessage, -- Message text.  
               @ErrorSeverity, -- Severity.  
               @ErrorState -- State.  
               ); 
END CATCH;

go

