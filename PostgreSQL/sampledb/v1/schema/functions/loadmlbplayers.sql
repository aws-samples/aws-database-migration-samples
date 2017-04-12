CREATE OR REPLACE FUNCTION dms_sample.loadmlbplayers()
RETURNS void
AS
$BODY$
DECLARE
    var_v_sport_team_id INTEGER;
    var_v_last_name VARCHAR(30);
    var_v_first_name VARCHAR(30);
    var_v_full_name VARCHAR(30);
    var_v_team_name VARCHAR(60);
    var_done VARCHAR(10) DEFAULT FALSE;
    mlb_players CURSOR FOR
    SELECT DISTINCT
        CASE LOWER(LTRIM(RTRIM(mlb_team_long::VARCHAR)::VARCHAR))
            WHEN LOWER('Anaheim Angels') THEN 'Los Angeles Angels'
            ELSE LTRIM(RTRIM(mlb_team_long::VARCHAR)::VARCHAR)
        END AS mlb_team_long, LTRIM(RTRIM(mlb_name::VARCHAR)::VARCHAR) AS name, esubstr(LTRIM(RTRIM(mlb_name::VARCHAR)::VARCHAR)::VARCHAR, 1::INT, POSITION(' '::VARCHAR IN mlb_name::VARCHAR)::INT) AS t_name, esubstr(LTRIM(RTRIM(mlb_name::VARCHAR)::VARCHAR)::VARCHAR, POSITION(' '::VARCHAR IN mlb_name::VARCHAR)::INT, LENGTH(mlb_name::VARCHAR)::INT) AS f_name
        FROM dms_sample.mlb_data;
BEGIN
    OPEN mlb_players;

    <<read_loop>>
    LOOP
        FETCH FROM mlb_players INTO var_v_team_name, var_v_last_name, var_v_first_name, var_v_full_name;

        IF NOT FOUND THEN
            EXIT read_loop;
        END IF;
        SELECT
            id::INTEGER
            INTO var_v_sport_team_id
            FROM dms_sample.sport_team
            WHERE LOWER(sport_type_name) = LOWER('baseball'::VARCHAR(15)) AND LOWER(sport_league_short_name) = LOWER('MLB'::VARCHAR(10)) AND LOWER(name) = LOWER(var_v_team_name::VARCHAR(30));
        INSERT INTO dms_sample.player (sport_team_id, last_name, first_name, full_name)
        VALUES (var_v_sport_team_id, var_v_last_name, var_v_first_name, var_v_full_name);
    END LOOP;
    CLOSE mlb_players;
END;
$BODY$
LANGUAGE  plpgsql;
