CREATE OR REPLACE FUNCTION dms_sample.loadnflplayers()
RETURNS void
AS
$BODY$
DECLARE
    var_v_team VARCHAR(10);
    var_v_name VARCHAR(60);
    var_v_l_name VARCHAR(30);
    var_v_f_name VARCHAR(30);
    var_v_sport_team_id INTEGER;
    var_done VARCHAR(10) DEFAULT FALSE;
    nfl_players CURSOR FOR
    SELECT
        team, name, esubstr(RTRIM(LTRIM(name::VARCHAR)::VARCHAR)::VARCHAR, 1::INT, POSITION(','::VARCHAR IN name::VARCHAR) - 1::NUMERIC::INT) AS l_name, RTRIM(LTRIM(esubstr(RTRIM(LTRIM(name::VARCHAR)::VARCHAR)::VARCHAR, POSITION(','::VARCHAR IN name::VARCHAR) + 1::NUMERIC::INT, LENGTH(name::VARCHAR)::INT)::VARCHAR)::VARCHAR) AS f_name
        FROM dms_sample.nfl_data;
BEGIN
    OPEN nfl_players;

    <<read_loop>>
    LOOP
        FETCH FROM nfl_players INTO var_v_team, var_v_name, var_v_l_name, var_v_f_name;

        IF NOT FOUND THEN
            EXIT read_loop;
        END IF;
        SELECT
            id::INTEGER
            INTO var_v_sport_team_id
            FROM dms_sample.sport_team
            WHERE LOWER(sport_type_name) = LOWER('football'::VARCHAR(15)) AND LOWER(sport_league_short_name) = LOWER('NFL'::VARCHAR(10)) AND LOWER(abbreviated_name) = LOWER(var_v_team);
        INSERT INTO dms_sample.player (sport_team_id, last_name, first_name, full_name)
        VALUES (var_v_sport_team_id, var_v_l_name, var_v_f_name, var_v_name);
    END LOOP;
    CLOSE nfl_players;
END;
$BODY$
LANGUAGE  plpgsql;

 CREATE OR REPLACE FUNCTION dms_sample.esubstr(
     str character varying,
     pos integer)
   RETURNS character varying AS
 $BODY$
 declare
 	len int;
 begin
 	if str is null or pos is null then
 		return null;
 	elsif pos = 0 then
 		return '';
 	elsif pos > 0 then
 		return substr(str, pos);
 	elsif pos < 0 then
 		len := length(str);
 		return substr(str, len+pos+1);
 	end if;
 end;
 $BODY$
   LANGUAGE plpgsql VOLATILE
  COST 100;
