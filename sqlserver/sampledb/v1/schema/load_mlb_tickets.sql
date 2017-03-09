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


BEGIN
  DECLARE @event_id BIGINT;
  DECLARE @event_cur CURSOR;
  SET @event_cur = CURSOR FOR
    SELECT id FROM sporting_event WHERE sport_type_name = 'baseball';

  OPEN @event_cur;
  FETCH @event_cur INTO @event_id;

  WHILE @@FETCH_STATUS = 0
  BEGIN
    BEGIN TRANSACTION;
     EXEC generate_tickets @event_id;
	COMMIT TRANSACTION;
	FETCH @event_cur INTO @event_id;
  END;
  CLOSE @event_cur;
  DEALLOCATE @event_cur;
END;

go

