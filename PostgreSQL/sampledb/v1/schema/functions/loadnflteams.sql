CREATE OR REPLACE FUNCTION dms_sample.loadnflteams()
RETURNS void
AS
$BODY$
DECLARE
    v_sport_type CHARACTER VARYING(10) DEFAULT 'football';
    v_league CHARACTER VARYING(10) DEFAULT 'NFL';
    v_division CHARACTER VARYING(10);
BEGIN
    v_division := 'AFC North';
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Baltimore Ravens', 'BAL', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Cincinnati Bengals', 'CIN', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Cleveland Browns', 'CLE', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Pittsburgh Steelers', 'PIT', v_sport_type, v_league, v_division);
    v_division := 'AFC South';
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Houston Texans', 'HOU', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Indianapolis Colts', 'IND', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Jacksonville Jaguars', 'JAX', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Tennessee Titans', 'TEN', v_sport_type, v_league, v_division);
    v_division := 'AFC East';
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Buffalo Bills', 'BUF', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Miami Dolphins', 'MIA', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('New England Patriots', 'NE', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('New York Jets', 'NYJ', v_sport_type, v_league, v_division);
    v_division := 'AFC West';
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Denver Broncos', 'DEN', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Kansas City Chiefs', 'KC', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Oakland Raiders', 'OAK', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('San Diego Chargers', 'SD', v_sport_type, v_league, v_division);
    v_division := 'NFC North';
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Chicago Bears', 'CHI', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Detroit Lions', 'DET', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Green Bay Packers', 'GB', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Minnesota Vikings', 'MIN', v_sport_type, v_league, v_division);
    v_division := 'NFC South';
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Atlanta Falcons', 'ATL', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Carolina Panthers', 'CAR', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('New Orleans Saints', 'NO', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Tampa Bay Buccaneers', 'TB', v_sport_type, v_league, v_division);
    v_division := 'NFC East';
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Dallas Cowboys', 'DAL', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('New York Giants', 'NYG', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Philadelphia Eagles', 'PHI', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Washington Redskins', 'WAS', v_sport_type, v_league, v_division);
    v_division := 'NFC West';
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Arizona Cardinals', 'ARI', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Los Angeles Rams', 'LA', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('San Francisco 49ers', 'SF', v_sport_type, v_league, v_division);
    INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
    VALUES ('Seattle Seahawks', 'SEA', v_sport_type, v_league, v_division);
END;
$BODY$
LANGUAGE  plpgsql;
