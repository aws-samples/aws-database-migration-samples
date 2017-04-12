CREATE OR REPLACE FUNCTION dms_sample.setnflteamhomefield()
RETURNS void
AS
$BODY$
DECLARE
    var_v_sport_location_id INTEGER;
    var_v_team VARCHAR(40);
    var_v_loc VARCHAR(40);
    var_done VARCHAR(40) DEFAULT FALSE;
    nsd_cur CURSOR FOR
    SELECT
        sport_location_id, team, location
        FROM dms_sample.nfl_stadium_data;
BEGIN
    OPEN nsd_cur;

    <<read_loop>>
    LOOP
        FETCH FROM nsd_cur INTO var_v_sport_location_id, var_v_team, var_v_loc;

        IF NOT FOUND THEN
            EXIT read_loop;
        END IF;
        UPDATE dms_sample.sport_team AS s
        SET home_field_id = var_v_sport_location_id::SMALLINT
            WHERE LOWER(s.name) = LOWER(var_v_team::VARCHAR(30)) AND LOWER(s.sport_league_short_name) = LOWER('NFL'::VARCHAR(10)) AND LOWER(s.sport_type_name) = LOWER('football'::VARCHAR(15));
    END LOOP;
    CLOSE nsd_cur;
END;
$BODY$
LANGUAGE  plpgsql;
