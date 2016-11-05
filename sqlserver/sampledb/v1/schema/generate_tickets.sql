-- drop procedure dbo.generate_tickets;
create procedure generate_tickets(@event_id BIGINT) as
BEGIN
  DECLARE @e_id BIGINT;
  DECLARE @loc_id   INT;
  DECLARE @event_cur CURSOR;
  SET @event_cur = CURSOR FOR
    SELECT id, location_id
    FROM sporting_event
    WHERE id = @event_id;


  -- randomly generated standard price between 30 and 50 dollars
  DECLARE @standard_price SMALLMONEY = ROUND(ABS(CHECKSUM(NewId())) % 20 + 30 + rand(),2);

  OPEN @event_cur;
  FETCH @event_cur INTO @e_id, @loc_id;

  WHILE @@FETCH_STATUS = 0
  BEGIN
    INSERT INTO sporting_event_ticket(sporting_event_id,sport_location_id,seat_level,seat_section,seat_row,seat,ticket_price)
    SELECT sporting_event.id
      ,seat.sport_location_id
      ,seat.seat_level
      ,seat.seat_section
      ,seat.seat_row
      ,seat.seat
      ,(CASE 
         WHEN seat.seat_type = 'luxury' THEN 3*@standard_price
         WHEN seat.seat_type = 'premium' THEN 2*@standard_price
         WHEN seat.seat_type = 'standard' THEN @standard_price
         WHEN seat.seat_type = 'sub-standard' THEN 0.8*@standard_price
         WHEN seat.seat_type = 'obstructed' THEN 0.5*@standard_price
         WHEN seat.seat_type = 'standing' THEN 0.5*@standard_price
      END ) ticket_price
    FROM sporting_event
       ,seat
    WHERE sporting_event.location_id = seat.sport_location_id
    AND   sporting_event.id = @e_id;

    FETCH @event_cur INTO @e_id, @loc_id;
  END;

END;

go
