CREATE OR REPLACE FUNCTION dms_sample.generateticketactivity(IN par_max_transactions INTEGER DEFAULT 10)
RETURNS void
AS
$BODY$
DECLARE
	min_person_id INTEGER;
	max_person_id INTEGER;
	rand_person_id INTEGER;
	min_event_id INTEGER;
	max_event_id INTEGER;
	rand_event_id INTEGER;
	tick_quantity INTEGER;
	var_current_txn INTEGER DEFAULT 0;
		
	
BEGIN
	min_person_id := (select MIN(id) FROM dms_sample.person);
	max_person_id := (select MAX(id) FROM dms_sample.person);
	min_event_id := (select MIN(sporting_event_id) FROM dms_sample.sporting_event_ticket);
	max_event_id := (select MAX(sporting_event_id) FROM dms_sample.sporting_event_ticket);

	WHILE var_current_txn < par_max_transactions LOOP
	rand_person_id := floor(random()*(max_person_id-min_person_id+min_person_id))+min_person_id;
	rand_event_id := floor(random()*(max_event_id-min_event_id+min_event_id))+min_event_id;
	tick_quantity := floor(random()*(10000-2000+2000))+2000;
      
    WITH ticket_list AS (
      SELECT
        id AS var_v_ticket_id, 
        seat_level AS var_v_seat_level,
        seat_section AS var_v_seat_section,
        seat_row AS var_v_seat_row
      FROM dms_sample.sporting_event_ticket
      WHERE sporting_event_id = rand_event_id
      ORDER BY seat_level NULLS FIRST, 
        LOWER(seat_section) NULLS FIRST, 
        LOWER(seat_row) NULLS FIRST
      LIMIT tick_quantity
    ),
     ticket_holder_list AS (
      UPDATE dms_sample.sporting_event_ticket
        SET ticketholder_id = rand_person_id
      FROM ticket_list
      WHERE id = var_v_ticket_id
      RETURNING id,
        ticketholder_id,
        ticket_price
    )
    INSERT INTO dms_sample.ticket_purchase_hist (
      sporting_event_ticket_id, 
      purchased_by_id, 
      transaction_date_time, 
      purchase_price)
    SELECT
      id,
      ticketholder_id, 
      clock_timestamp()::TIMESTAMP, 
      ticket_price
    FROM ticket_holder_list;

	var_current_txn := (var_current_txn + 1)::INT;
	END LOOP;
END;
$BODY$
LANGUAGE  plpgsql;
