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

