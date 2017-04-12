CREATE OR REPLACE FUNCTION dms_sample.generatenflseason()
RETURNS void
AS
$BODY$
DECLARE
    var_v_date_offset INTEGER DEFAULT 0;
    var_v_event_date TIMESTAMP WITHOUT TIME ZONE;
    var_v_sport_division_short_name VARCHAR(10);
    var_v_day_increment INTEGER;
    var_div_done VARCHAR(10) DEFAULT FALSE;
    div_cur CURSOR FOR
    SELECT DISTINCT
        sport_division_short_name
        FROM dms_sample.sport_team
        WHERE LOWER(sport_type_name) = LOWER('football'::VARCHAR(15)) AND LOWER(sport_league_short_name) = LOWER('NFL'::VARCHAR(10));
    var_v_team1_id INTEGER;
    var_v_team1_home_field_id INTEGER;
    var_team1_done VARCHAR(10) DEFAULT FALSE;
    team1 CURSOR FOR
    SELECT
        id, home_field_id
        FROM dms_sample.sport_team
        WHERE LOWER(sport_division_short_name) = LOWER(var_v_sport_division_short_name) AND LOWER(sport_type_name) = LOWER('football'::VARCHAR(15)) AND LOWER(sport_league_short_name) = LOWER('NFL'::VARCHAR(10))
        ORDER BY id NULLS FIRST;
    var_v_team2_id INTEGER;
    var_v_team2_home_field_id INTEGER;
    var_team2_done VARCHAR(10) DEFAULT FALSE;
    team2 CURSOR FOR
    SELECT
        id, home_field_id
        FROM dms_sample.sport_team
        WHERE id > var_v_team1_id::INTEGER AND LOWER(sport_division_short_name) = LOWER(var_v_sport_division_short_name) AND LOWER(sport_type_name) = LOWER('football'::VARCHAR(15)) AND LOWER(sport_league_short_name) = LOWER('NFL'::VARCHAR(10))
        ORDER BY id NULLS FIRST;
    var_v_team3_id INTEGER;
    var_v_team3_home_field_id INTEGER;
    var_team3_done VARCHAR(10) DEFAULT FALSE;
    team3 CURSOR FOR
    SELECT
        id, home_field_id
        FROM dms_sample.sport_team
        WHERE id < var_v_team1_id::INTEGER AND LOWER(sport_division_short_name) = LOWER(var_v_sport_division_short_name) AND LOWER(sport_type_name) = LOWER('football'::VARCHAR(15)) AND LOWER(sport_league_short_name) = LOWER('NFL'::VARCHAR(10))
        ORDER BY id NULLS FIRST;
    var_i INTEGER DEFAULT 1;
    var_v_nfc_conf VARCHAR(10);
    var_v_afc_conf VARCHAR(10);
    var_v_rownum INTEGER DEFAULT 1;
    var_v_t2_id INTEGER;
    var_v_t2_field_id INTEGER;
    var_v_t1_id INTEGER;
    var_v_t1_field_id INTEGER;
    var_v_dt TIMESTAMP WITHOUT TIME ZONE;
    var_cross_div_done VARCHAR(10) DEFAULT FALSE;
    cross_div_cur CURSOR FOR
    SELECT
        a.id AS t2_id, a.home_field_id AS t2_field_id, b.id AS t1_id, b.home_field_id AS t1_field_id
        FROM dms_sample.sport_team AS a, dms_sample.sport_team AS b
        WHERE LOWER(a.sport_division_short_name) = LOWER(var_v_afc_conf) AND LOWER(b.sport_division_short_name) = LOWER(var_v_nfc_conf)
        ORDER BY LOWER(a.name) NULLS FIRST, LOWER(b.name) NULLS FIRST;
  
BEGIN
    OPEN div_cur;

    <<div_loop>>
    LOOP
        FETCH FROM div_cur INTO var_v_sport_division_short_name;

        IF NOT FOUND THEN
            CLOSE div_cur;
            EXIT div_loop;
        END IF;
        var_v_date_offset := 0::INTEGER;

        <<block1>>
        BEGIN
            OPEN team1;

            <<team1_loop>>
            LOOP
                FETCH FROM team1 INTO var_v_team1_id, var_v_team1_home_field_id;

                IF NOT FOUND THEN
                    CLOSE team1;
                    EXIT team1_loop;
                END IF;
                var_v_day_increment := (1::NUMERIC - date_part('DOW', dms_sample.estr_to_date(CONCAT('01,9,', dms_sample.edate_format(clock_timestamp()::TIMESTAMP::TIMESTAMPTZ, '%Y'))::TEXT, '%d,%m,%Y')::DATE))::INTEGER;
                var_v_event_date := dms_sample.edate_add(dms_sample.estr_to_date(CONCAT('01,9,', dms_sample.edate_format(clock_timestamp()::TIMESTAMP::TIMESTAMPTZ, '%Y'))::TEXT, '%d,%m,%Y')::TIMESTAMP, (var_v_day_increment::NUMERIC + 7::NUMERIC * var_v_date_offset::NUMERIC)::TEXT, 'DAY'::TEXT)::TIMESTAMP WITHOUT TIME ZONE;

                <<block2>>
                BEGIN
                    OPEN team2;

                    <<team2_loop>>
                    LOOP
                        FETCH FROM team2 INTO var_v_team2_id, var_v_team2_home_field_id;

                        IF NOT FOUND THEN
                            CLOSE team2;
                            EXIT team2_loop;
                        END IF;
                        INSERT INTO dms_sample.sporting_event (sport_type_name, home_team_id, away_team_id, location_id, start_date_time, start_date)
                        VALUES ('football', var_v_team1_id, var_v_team2_id, var_v_team1_home_field_id, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT)::TIMESTAMP WITHOUT TIME ZONE, var_v_event_date);
                        var_v_event_date := dms_sample.edate_add(var_v_event_date::TIMESTAMP, (7)::TEXT, 'DAY'::TEXT)::TIMESTAMP WITHOUT TIME ZONE;
                    END LOOP;
                END BLOCK2;

                <<block3>>
                BEGIN
                    OPEN team3;

                    <<team3_loop>>
                    LOOP
                        FETCH FROM team3 INTO var_v_team3_id, var_v_team3_home_field_id;

                        IF NOT FOUND THEN
                            CLOSE team3;
                            EXIT team3_loop;
                        END IF;
                        INSERT INTO dms_sample.sporting_event (sport_type_name, home_team_id, away_team_id, location_id, start_date_time, start_date)
                        VALUES ('football', var_v_team1_id, var_v_team3_id, var_v_team1_home_field_id, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT)::TIMESTAMP WITHOUT TIME ZONE, var_v_event_date);
                        var_v_event_date := dms_sample.edate_add(var_v_event_date::TIMESTAMP, (7)::TEXT, 'DAY'::TEXT)::TIMESTAMP WITHOUT TIME ZONE;
                    END LOOP;
                END BLOCK3;
                var_v_date_offset := (var_v_date_offset::NUMERIC + 1::NUMERIC)::INTEGER;
            END LOOP;
        END BLOCK1;
    END LOOP;
    DROP TABLE IF EXISTS v_date_tab;
    CREATE TEMPORARY TABLE v_date_tab
    (id INTEGER PRIMARY KEY,
        dt VARCHAR(100));
    var_v_event_date := dms_sample.edate_add(var_v_event_date::TIMESTAMP, (7)::TEXT, 'DAY'::TEXT)::TIMESTAMP WITHOUT TIME ZONE;
    INSERT INTO v_date_tab
    VALUES (1, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
    INSERT INTO v_date_tab
    VALUES (6, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
    INSERT INTO v_date_tab
    VALUES (11, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
    INSERT INTO v_date_tab
    VALUES (16, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
    var_v_event_date := dms_sample.edate_add(var_v_event_date::TIMESTAMP, (7)::TEXT, 'DAY'::TEXT)::TIMESTAMP WITHOUT TIME ZONE;
    INSERT INTO v_date_tab
    VALUES (2, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
    INSERT INTO v_date_tab
    VALUES (7, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
    INSERT INTO v_date_tab
    VALUES (12, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
    INSERT INTO v_date_tab
    VALUES (13, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
    var_v_event_date := dms_sample.edate_add(var_v_event_date::TIMESTAMP, (7)::TEXT, 'DAY'::TEXT)::TIMESTAMP WITHOUT TIME ZONE;
    INSERT INTO v_date_tab
    VALUES (3, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
    INSERT INTO v_date_tab
    VALUES (8, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
    INSERT INTO v_date_tab
    VALUES (9, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
    INSERT INTO v_date_tab
    VALUES (14, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
    var_v_event_date := dms_sample.edate_add(var_v_event_date::TIMESTAMP, (7)::TEXT, 'DAY'::TEXT)::TIMESTAMP WITHOUT TIME ZONE;
    INSERT INTO v_date_tab
    VALUES (4, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
    INSERT INTO v_date_tab
    VALUES (5, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
    INSERT INTO v_date_tab
    VALUES (10, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
    INSERT INTO v_date_tab
    VALUES (15, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
    DROP TABLE IF EXISTS v_nfc_tab;
    CREATE TEMPORARY TABLE v_nfc_tab
    (id INTEGER,
        conf VARCHAR(10));
    INSERT INTO v_nfc_tab
    VALUES (1, 'NFC North'),
    (2, 'NFC East'),
    (3, 'NFC South'),
    (4, 'NFC West');
    DROP TABLE IF EXISTS v_afc_tab;
    CREATE TEMPORARY TABLE v_afc_tab
    (id INTEGER,
        conf VARCHAR(10));
    INSERT INTO v_afc_tab
    VALUES (1, 'AFC North'),
    (2, 'AFC East'),
    (3, 'AFC South'),
    (4, 'AFC West');

    <<cross_conf_block>>
    BEGIN
        WHILE var_i <= 4::INTEGER LOOP
            SELECT
                conf
                INTO var_v_nfc_conf
                FROM v_nfc_tab
                WHERE id = var_i;
            SELECT
                conf
                INTO var_v_afc_conf
                FROM v_afc_tab
                WHERE id = 1::INTEGER;

            <<cc_block1>>
            BEGIN
                OPEN cross_div_cur;

                <<cross_div_cur_loop>>
                LOOP
                    FETCH FROM cross_div_cur INTO var_v_t2_id, var_v_t2_field_id, var_v_t1_id, var_v_t1_field_id;

                    IF NOT FOUND THEN
                        CLOSE cross_div_cur;
                        EXIT cross_div_cur_loop;
                    END IF;
                    SELECT
                        dt
                        INTO var_v_dt
                        FROM v_date_tab
                        WHERE id = var_v_rownum;

                    IF (var_v_rownum::NUMERIC % 2::NUMERIC) = 0 THEN
                        INSERT INTO dms_sample.sporting_event (sport_type_name, home_team_id, away_team_id, location_id, start_date_time, start_date)
                        VALUES ('football', var_v_t2_id, var_v_t1_id, var_v_t2_field_id, var_v_dt, var_v_dt);
                    ELSE
                        INSERT INTO dms_sample.sporting_event (sport_type_name, home_team_id, away_team_id, location_id, start_date_time, start_date)
                        VALUES ('football', var_v_t1_id, var_v_t2_id, var_v_t1_field_id, var_v_dt, var_v_dt);
                    END IF;
                END LOOP;
            END CC_BLOCK1;
            var_i := (var_i::NUMERIC + 1::NUMERIC)::INTEGER;
        END LOOP;
        DELETE FROM v_date_tab;
        var_v_event_date := dms_sample.edate_add(var_v_event_date::TIMESTAMP, (7)::TEXT, 'DAY'::TEXT)::TIMESTAMP WITHOUT TIME ZONE;
        INSERT INTO v_date_tab
        VALUES (1, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (6, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (11, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (16, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        var_v_event_date := dms_sample.edate_add(var_v_event_date::TIMESTAMP, (7)::TEXT, 'DAY'::TEXT)::TIMESTAMP WITHOUT TIME ZONE;
        INSERT INTO v_date_tab
        VALUES (2, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (7, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (12, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (13, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        var_v_event_date := dms_sample.edate_add(var_v_event_date::TIMESTAMP, (7)::TEXT, 'DAY'::TEXT)::TIMESTAMP WITHOUT TIME ZONE;
        INSERT INTO v_date_tab
        VALUES (3, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (8, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (9, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (14, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        var_v_event_date := dms_sample.edate_add(var_v_event_date::TIMESTAMP, (7)::TEXT, 'DAY'::TEXT)::TIMESTAMP WITHOUT TIME ZONE;
        INSERT INTO v_date_tab
        VALUES (4, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (5, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (10, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (15, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        DELETE FROM v_nfc_tab;
        INSERT INTO v_nfc_tab
        VALUES (1, 'NFC North'),
        (2, 'NFC East'),
        (3, 'NFC South'),
        (4, 'NFC West');
        DELETE FROM v_afc_tab;
        INSERT INTO v_afc_tab
        VALUES (1, 'AFC West'),
        (2, 'AFC North'),
        (3, 'AFC East'),
        (4, 'AFC South');
        var_i := 1::INTEGER;

        WHILE var_i <= 4::INTEGER LOOP
            SELECT
                conf
                INTO var_v_nfc_conf
                FROM v_nfc_tab
                WHERE id = var_i;
            SELECT
                conf
                INTO var_v_afc_conf
                FROM v_afc_tab
                WHERE id = 1::INTEGER;

            <<cc_block2>>
            BEGIN
                OPEN cross_div_cur;

                <<cross_div_cur_loop>>
                LOOP
                    FETCH FROM cross_div_cur INTO var_v_t2_id, var_v_t2_field_id, var_v_t1_id, var_v_t1_field_id;

                    IF NOT FOUND THEN
                        CLOSE cross_div_cur;
                        EXIT cross_div_cur_loop;
                    END IF;
                    SELECT
                        dt
                        INTO var_v_dt
                        FROM v_date_tab
                        WHERE id = var_v_rownum;

                    IF (var_v_rownum::NUMERIC % 2::NUMERIC) = 0 THEN
                        INSERT INTO dms_sample.sporting_event (sport_type_name, home_team_id, away_team_id, location_id, start_date_time, start_date)
                        VALUES ('football', var_v_t2_id, var_v_t1_id, var_v_t2_field_id, var_v_dt, var_v_dt);
                    ELSE
                        INSERT INTO dms_sample.sporting_event (sport_type_name, home_team_id, away_team_id, location_id, start_date_time, start_date)
                        VALUES ('football', var_v_t1_id, var_v_t2_id, var_v_t1_field_id, var_v_dt, var_v_dt);
                    END IF;
                END LOOP;
            END CC_BLOCK2;
            var_i := (var_i::NUMERIC + 1::NUMERIC)::INTEGER;
        END LOOP;
        DELETE FROM v_date_tab;
        var_v_event_date := dms_sample.edate_add(var_v_event_date::TIMESTAMP, (7)::TEXT, 'DAY'::TEXT)::TIMESTAMP WITHOUT TIME ZONE;
        INSERT INTO v_date_tab
        VALUES (1, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (6, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (11, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (16, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        var_v_event_date := dms_sample.edate_add(var_v_event_date::TIMESTAMP, (7)::TEXT, 'DAY'::TEXT)::TIMESTAMP WITHOUT TIME ZONE;
        INSERT INTO v_date_tab
        VALUES (2, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (7, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (12, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (13, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        var_v_event_date := dms_sample.edate_add(var_v_event_date::TIMESTAMP, (7)::TEXT, 'DAY'::TEXT)::TIMESTAMP WITHOUT TIME ZONE;
        INSERT INTO v_date_tab
        VALUES (3, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (8, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (9, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (14, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        var_v_event_date := dms_sample.edate_add(var_v_event_date::TIMESTAMP, (7)::TEXT, 'DAY'::TEXT)::TIMESTAMP WITHOUT TIME ZONE;
        INSERT INTO v_date_tab
        VALUES (4, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (5, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (10, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        INSERT INTO v_date_tab
        VALUES (15, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT));
        DELETE FROM v_nfc_tab;
        INSERT INTO v_nfc_tab
        VALUES (1, 'NFC North'),
        (2, 'NFC East'),
        (3, 'NFC South'),
        (4, 'NFC West');
        DELETE FROM v_afc_tab;
        INSERT INTO v_afc_tab
        VALUES (1, 'AFC South'),
        (2, 'AFC West'),
        (3, 'AFC North'),
        (4, 'AFC East');
        var_i := 1::INTEGER;

        WHILE var_i <= 4::INTEGER LOOP
            SELECT
                conf
                INTO var_v_nfc_conf
                FROM v_nfc_tab
                WHERE id = var_i;
            SELECT
                conf
                INTO var_v_afc_conf
                FROM v_afc_tab
                WHERE id = 1::INTEGER;

            <<cc_block3>>
            BEGIN
                OPEN cross_div_cur;

                <<cross_div_cur_loop>>
                LOOP
                    FETCH FROM cross_div_cur INTO var_v_t2_id, var_v_t2_field_id, var_v_t1_id, var_v_t1_field_id;

                    IF NOT FOUND THEN
                        CLOSE cross_div_cur;
                        EXIT cross_div_cur_loop;
                    END IF;
                    SELECT
                        dt
                        INTO var_v_dt
                        FROM v_date_tab
                        WHERE id = var_v_rownum;

                    IF (var_v_rownum::NUMERIC % 2::NUMERIC) = 0 THEN
                        INSERT INTO dms_sample.sporting_event (sport_type_name, home_team_id, away_team_id, location_id, start_date_time, start_date)
                        VALUES ('football', var_v_t2_id, var_v_t1_id, var_v_t2_field_id, var_v_dt, var_v_dt);
                    ELSE
                        INSERT INTO dms_sample.sporting_event (sport_type_name, home_team_id, away_team_id, location_id, start_date_time, start_date)
                        VALUES ('football', var_v_t1_id, var_v_t2_id, var_v_t1_field_id, var_v_dt, var_v_dt);
                    END IF;
                END LOOP;
            END CC_BLOCK3;
            var_i := (var_i::NUMERIC + 1::NUMERIC)::INTEGER;
        END LOOP;
    END CROSS_CONF_BLOCK;
END;
$BODY$
LANGUAGE  plpgsql;





CREATE OR REPLACE FUNCTION dms_sample.estr_to_date(
    str text,
    format text)
  RETURNS date AS
$BODY$
DECLARE
	res date;
BEGIN

	format := replace(format, '%Y', 'YYYY');
	format := replace(format, '%y', 'YY');
	format := replace(format, '%b', 'MON');
	format := replace(format, '%M', 'MONTH');
	format := replace(format, '%m', 'MM');
	format := replace(format, '%a', 'DY');
	format := replace(format, '%d', 'DD');
	format := replace(format, '%H', 'HH24');
	format := replace(format, '%h', 'HH');
	format := replace(format, '%i', 'MI');
	format := replace(format, '%s', 'SS');

	BEGIN
		res := TO_DATE(str, format);
    EXCEPTION
    WHEN OTHERS THEN
    	res := null;
	END;

    return res;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
