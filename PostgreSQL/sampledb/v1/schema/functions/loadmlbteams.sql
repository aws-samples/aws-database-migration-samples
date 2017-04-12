CREATE OR REPLACE FUNCTION dms_sample.loadmlbteams()
RETURNS void
AS
$BODY$
DECLARE
    v_div DMS_SAMPLE.SPORT_DIVISION.short_name%TYPE;
    mlb_teams CURSOR FOR
    SELECT DISTINCT
        CASE TRIM(mlb_team)
            WHEN 'AAA' THEN 'LAA'
            ELSE mlb_team
        END AS a_name,
        CASE TRIM(mlb_team_long)
            WHEN 'Anaheim Angels' THEN 'Los Angeles Angels'
            ELSE mlb_team_long
        END AS l_name
        FROM dms_sample.mlb_data;
BEGIN
    FOR trec IN mlb_teams LOOP
        CASE
            WHEN trec.a_name IN ('BAL', 'BOS', 'TOR', 'TB', 'NYY') THEN
                v_div := 'AL East';
            WHEN trec.a_name IN ('CLE', 'DET', 'KC', 'CWS', 'MIN') THEN
                v_div := 'AL Central';
            WHEN trec.a_name IN ('TEX', 'SEA', 'HOU', 'OAK', 'LAA') THEN
                v_div := 'AL West';
            WHEN trec.a_name IN ('WSH', 'MIA', 'NYM', 'PHI', 'ATL') THEN
                v_div := 'NL East';
            WHEN trec.a_name IN ('CHC', 'STL', 'PIT', 'MIL', 'CIN') THEN
                v_div := 'NL Central';
            WHEN trec.a_name IN ('COL', 'SD', 'LAD', 'SF', 'ARI') THEN
                v_div := 'NL West';
        END CASE;
        INSERT INTO dms_sample.sport_team (name, abbreviated_name, sport_type_name, sport_league_short_name, sport_division_short_name)
        VALUES (trec.l_name, trec.a_name, 'baseball', 'MLB', v_div);
    END LOOP;
END;
$BODY$
LANGUAGE  plpgsql;
