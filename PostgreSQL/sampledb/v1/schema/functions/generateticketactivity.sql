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
	PERFORM dms_sample.selltickets(rand_person_id, rand_event_id, tick_quantity);
	var_current_txn := (var_current_txn + 1)::INT;
	END LOOP;
END;
$BODY$
LANGUAGE  plpgsql;
