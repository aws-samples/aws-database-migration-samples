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


drop procedure generateTicketActivity;
go

create procedure generateTicketActivity(@max_transactions INT = 1000) as
BEGIN TRY
  DECLARE @min_person_id INT;
  DECLARE @max_person_id INT;
  DECLARE @open_events TABLE (rownum INT NOT NULL PRIMARY KEY CLUSTERED, id BIGINT);
  DECLARE @min_row INT;
  DECLARE @max_row INT;
  DECLARE @target_row INT;
  DECLARE @event_id BIGINT;
  DECLARE @target_person_id INT;
  DECLARE @person_id INT;
  DECLARE @quantity INT;
  DECLARE @current_txn INT = 0;
  DECLARE @reset_events INT = 1;

  SELECT @min_person_id = MIN(id), @max_person_id = MAX(id) from person;

  WHILE @current_txn < @max_transactions 
    BEGIN
	  IF @reset_events = 1
	    BEGIN
		  DELETE FROM @open_events;
          INSERT INTO @open_events 
          SELECT ROW_NUMBER() OVER (order by start_date), id FROM sporting_event WHERE sold_out <> 1 ORDER BY start_date;
          SELECT @min_row = min(rownum), @max_row = max(rownum) FROM @open_events;
          SET @reset_events = 0;
        END;

      SET @target_row = dbo.rand_int(@min_row, @max_row);
      select @event_id = id from @open_events where rownum = @target_row;

      SET @target_person_id = dbo.rand_int(@min_person_id, @max_person_id);
      select @person_id = MIN(id) from person where id > @target_person_id-1;

      SET @quantity = dbo.rand_int(1,6);

	  BEGIN TRY 
	    exec dbo.sellTickets @person_id, @event_id, @quantity;
        SET @current_txn = @current_txn +1;
	    -- WAITFOR DELAY '00:00:00.01'; /* we can add this in the future if needed. */
        PRINT(CONCAT('event:',@event_id, ' person:', @person_id,' quantity: ',@quantity));
	  END TRY
	  BEGIN CATCH
	    SET @reset_events = 1;  -- If we fail to sell tickets to this event, we reload the open events table as this one is sold out
	  END CATCH

	END;
END TRY
BEGIN CATCH
  PRINT('Error: Uable to generate tickets...');
END CATCH;

go
