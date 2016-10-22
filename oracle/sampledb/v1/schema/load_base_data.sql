--------------------------------------------------------------
--
-- The following scripts load raw data used to generate the
-- sample database
--
--------------------------------------------------------------

@schema/mlb_data.tab
@schema/mlb_data.sql
commit;
@schema/name_data.tab
@schema/name_data.sql
commit;
@schema/nfl_data.tab
@schema/nfl_data.sql
commit;
@schema/nfl_stadium_data.tab
@schema/nfl_stadium_data.sql
commit;
