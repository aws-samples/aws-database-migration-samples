CREATE OR REPLACE FUNCTION dms_sample.generatemlbseason()
RETURNS void
AS
$BODY$
DECLARE
    var_v_date_offset INTEGER DEFAULT 0;
    var_v_t1_id INTEGER;
    var_v_t1_home_id INTEGER;
    var_v_event_date TIMESTAMP WITHOUT TIME ZONE;
    var_v_day_increment INTEGER;
    var_t1_done varchar(10) DEFAULT FALSE;
    team1 CURSOR FOR
    SELECT
        id, home_field_id
        FROM dms_sample.sport_team
        WHERE LOWER(sport_league_short_name) = LOWER('MLB'::VARCHAR(10)) AND LOWER(sport_type_name) = LOWER('baseball'::VARCHAR(15))
        ORDER BY id NULLS FIRST;
    var_v_t2_id INTEGER;
    var_v_t2_home_id INTEGER;
    var_t2_done varchar(10) DEFAULT FALSE;
    team2 CURSOR FOR
    SELECT
        id, home_field_id
        FROM dms_sample.sport_team
        WHERE id > var_v_t1_id::INTEGER AND LOWER(sport_league_short_name) = LOWER('MLB'::VARCHAR(10)) AND LOWER(sport_type_name) = LOWER('baseball'::VARCHAR(15))
        ORDER BY id NULLS FIRST;
    var_v_t3_id INTEGER;
    var_v_t3_home_id INTEGER;
    var_t3_done varchar(10) DEFAULT FALSE;
    team3 CURSOR FOR
    SELECT
        id, home_field_id
        FROM dms_sample.sport_team
        WHERE id < var_v_t1_id::INTEGER AND LOWER(sport_league_short_name) = LOWER('MLB'::VARCHAR(10)) AND LOWER(sport_type_name) = LOWER('baseball'::VARCHAR(15))
        ORDER BY id NULLS FIRST;
BEGIN
    OPEN team1;

    <<team1_loop>>
    LOOP
        FETCH FROM team1 INTO var_v_t1_id, var_v_t1_home_id;

        IF NOT FOUND THEN
            CLOSE team1;
            EXIT team1_loop;
        END IF;
        var_v_day_increment := (7::NUMERIC - date_part('DOW', dms_sample.estr_to_date(CONCAT('31,3,', dms_sample.edate_format(clock_timestamp()::TIMESTAMP::TIMESTAMPTZ, '%Y'))::TEXT, '%d,%m,%Y')::DATE))::INTEGER;
        var_v_event_date := dms_sample.edate_add(dms_sample.estr_to_date(CONCAT('31,3,', dms_sample.edate_format(clock_timestamp()::TIMESTAMP::TIMESTAMPTZ, '%Y'))::TEXT, '%d,%m,%Y')::TIMESTAMP, (var_v_day_increment::NUMERIC + 7::NUMERIC * var_v_date_offset::NUMERIC)::TEXT, 'DAY'::TEXT)::TIMESTAMP WITHOUT TIME ZONE;

        <<block2>>
        BEGIN
            OPEN team2;

            <<team2_loop>>
            LOOP
                FETCH FROM team2 INTO var_v_t2_id, var_v_t2_home_id;

                IF NOT FOUND THEN
                    CLOSE team2;
                    EXIT team2_loop;
                END IF;
                INSERT INTO dms_sample.sporting_event (sport_type_name, home_team_id, away_team_id, location_id, start_date_time, start_date)
                VALUES ('baseball', var_v_t1_id, var_v_t2_id, var_v_t1_home_id, var_v_event_date, dms_sample.edate_add(var_v_event_date::TIMESTAMP, 
                (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT)::TIMESTAMP WITHOUT TIME ZONE);
                
                var_v_event_date := dms_sample.edate_add(var_v_event_date::TIMESTAMP, (7)::TEXT, 'DAY'::TEXT)::TIMESTAMP WITHOUT TIME ZONE;
            END LOOP;
        END BLOCK2;

        <<block3>>
        BEGIN
            OPEN team3;

            <<team3_loop>>
            LOOP
                FETCH FROM team3 INTO var_v_t3_id, var_v_t3_home_id;

                IF NOT FOUND THEN
                    CLOSE team3;
                    EXIT team3_loop;
                END IF;
                var_v_event_date := dms_sample.edate_add(var_v_event_date::TIMESTAMP, (7)::TEXT, 'DAY'::TEXT)::TIMESTAMP WITHOUT TIME ZONE;
                INSERT INTO dms_sample.sporting_event (sport_type_name, home_team_id, away_team_id, location_id, start_date_time, start_date)
                VALUES ('baseball', var_v_t1_id, var_v_t3_id, var_v_t1_home_id, var_v_event_date, dms_sample.edate_add(var_v_event_date::TIMESTAMP, (FLOOR((RANDOM() * (19::NUMERIC - 12::NUMERIC + 1::NUMERIC))::NUMERIC) + 12::NUMERIC)::TEXT, 'HOUR'::TEXT)::TIMESTAMP WITHOUT TIME ZONE);
            END LOOP;
        END BLOCK3;
    END LOOP;
END;
$BODY$
LANGUAGE  plpgsql;


CREATE OR REPLACE FUNCTION dms_sample.edate_add(
    expr1 timestamp with time zone,
    expr2 text,
    unit anyelement)
  RETURNS anyelement AS
$BODY$
BEGIN
  CASE upper(unit)
      WHEN 'MICROSECOND' THEN return expr1::timestamptz + concat(expr2,' microseconds')::interval;
      WHEN 'SECOND' THEN return expr1::timestamp + concat(expr2,' second')::interval;
      WHEN 'MINUTE' THEN return expr1::timestamp + concat(expr2,' minute')::interval;
      WHEN 'HOUR' THEN return expr1::timestamp + concat(expr2,' hour')::interval;
      WHEN 'DAY' THEN return expr1::timestamp + concat(expr2,' day')::interval;
      WHEN 'MONTH' THEN return expr1::timestamp + concat(expr2,' month')::interval;
      WHEN 'QUARTER' THEN return expr1::timestamp + concat(expr2,' quarter')::interval;
      WHEN 'YEAR' THEN return expr1::timestamp + concat(expr2,' year')::interval;
      WHEN 'SECOND_MICROSECOND' THEN return expr1::timestamptz + concat(expr2,' microseconds')::interval;
      WHEN 'MINUTE_MICROSECOND' THEN return expr1::timestamptz + concat(expr2,' microseconds')::interval;
      WHEN 'MINUTE_SECOND' THEN return expr1::timestamp + concat(expr2,' second')::interval;
      WHEN 'HOUR_MICROSECOND' THEN return expr1::timestamp + concat(expr2,' microseconds')::interval;
      WHEN 'HOUR_SECOND' THEN return expr1::timestamp + concat(expr2,' second')::interval;
      WHEN 'HOUR_MINUTE' THEN return expr1::timestamp + concat(expr2,' minute')::interval;
      WHEN 'DAY_MICROSECOND' THEN return expr1::timestamp + concat(expr2,' microseconds')::interval;
      WHEN 'DAY_SECOND' THEN return expr1::timestamp + concat(expr2,' second')::interval;
      WHEN 'DAY_MINUTE' THEN return expr1::timestamp + concat(expr2,' minute')::interval;
      WHEN 'DAY_HOUR' THEN return expr1::timestamp + concat(expr2,' hour')::interval;
      WHEN 'YEAR_MONTH' THEN return expr1::timestamp + concat(expr2,' month')::interval;
      WHEN 'WEEK' THEN return expr1::timestamp + concat(expr2,' week')::interval;
      ELSE RAISE EXCEPTION 'Incorrect value for parameter "unit"!';
  END CASE;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
  
  CREATE OR REPLACE FUNCTION dms_sample.estr_to_date(
      str text,
      format text)
    RETURNS date AS
  $BODY$
  DECLARE
  	res date;
  BEGIN
  /*
  Version: 1
  Developer: Pogorelov
  Created: 20160212
  Last Updated:
  */
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



CREATE OR REPLACE FUNCTION dms_sample.edate_format(
    expr timestamp with time zone,
    format text)
  RETURNS text AS
$BODY$
DECLARE res text;
DECLARE pos integer;
BEGIN
/*
Version: 2
Developer: Pogorelov
Created: 20160215
Last Updated: 20160309
*/

	SELECT position('%U' in format) INTO pos;
    IF pos <> 0 THEN
     RAISE EXCEPTION 'Format parameter % is not supported!', '''%U''';
    END if;

	SELECT position('%u' in format) INTO pos;
    IF pos <> 0 THEN
     RAISE EXCEPTION 'Format parameter % is not supported!', '''%u''';
    END if;

	SELECT position('%V' in format) INTO pos;
    IF pos <> 0 THEN
     RAISE EXCEPTION 'Format parameter % is not supported!', '''%V''';
    END if;

	SELECT position('%X' in format) INTO pos;
    IF pos <> 0 THEN
     RAISE EXCEPTION 'Format parameter % is not supported!', '''%X''';
    END if;
/*
%U	Week (00..53), where Sunday is the first day of the week; WEEK() mode 0
%u	Week (00..53), where Monday is the first day of the week; WEEK() mode 1
%V	Week (01..53), where Sunday is the first day of the week; WEEK() mode 2; used with %X
%X	Year for the week where Sunday is the first day of the week, numeric, four digits; used with %V
*/

    CASE date_part('DAY', expr::date)
      WHEN 1,21,31 THEN format := replace(format, '%D', 'FMDD"st"');
      WHEN 2,22 THEN format := replace(format, '%D', 'FMDD"nd"');
      WHEN 3,23 THEN format := replace(format, '%D', 'FMDD"rd"');
      ELSE format := replace(format, '%D', 'FMDD"th"');
    END CASE;

	format := replace(format, '%a', 'DY');
	format := replace(format, '%b', 'MON');
	format := replace(format, '%c', 'FMMM');
	format := replace(format, '%d', 'DD');
	format := replace(format, '%e', 'FMDD');
	format := replace(format, '%f', 'US');
	format := replace(format, '%H', 'HH24');
	format := replace(format, '%h', 'HH');
	format := replace(format, '%j', 'DDD');
	format := replace(format, '%I', 'HH');
	format := replace(format, '%i', 'MI');
	format := replace(format, '%k', 'FMHH24');
	format := replace(format, '%l', 'FMHH');
	format := replace(format, '%M', 'MONTH');
	format := replace(format, '%m', 'MM');
	format := replace(format, '%p', 'AM');
	format := replace(format, '%r', 'HH:MI:SS AM');
	format := replace(format, '%S', 'SS');
	format := replace(format, '%s', 'SS');
	format := replace(format, '%T', 'HH24:MI:SS');
	format := replace(format, '%v', 'IW');
	format := replace(format, '%W', 'Day');
	format := replace(format, '%w', 'D');
	format := replace(format, '%x', 'IYYY');
	format := replace(format, '%Y', 'YYYY');
	format := replace(format, '%y', 'YY');

	BEGIN
		res := TO_CHAR(expr, format);
    EXCEPTION
    WHEN OTHERS THEN
    	res := null;
	END;

    return res;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
