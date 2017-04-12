CREATE OR REPLACE FUNCTION dms_sample.generatesporttickets(IN par_p_sport VARCHAR, OUT p_refcur refcursor)
AS
$BODY$
DECLARE
    var_v_event_id BIGINT;
    var_all_done varchar(10) DEFAULT FALSE;
    event_cur2 CURSOR FOR
    SELECT
        id
        FROM dms_sample.sporting_event
        WHERE LOWER(sport_type_name) = LOWER(par_p_sport);
BEGIN
    OPEN p_refcur FOR
    SELECT
        par_p_sport;
    OPEN event_cur2;

    <<event_loop>>
    LOOP
        FETCH event_cur2 INTO var_v_event_id;

        IF NOT FOUND THEN
            CLOSE event_cur2;
            EXIT event_loop;
        END IF;
        PERFORM dms_sample.generatetickets(var_v_event_id);
    END LOOP;
END;
$BODY$
LANGUAGE  plpgsql;
