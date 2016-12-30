--------------------------------------------------------------
--
-- The following scripts load raw data used to generate the
-- sample database
--
--------------------------------------------------------------
use dms_sample
source ./schema/mlb_data.tab
source ./data/mlb_data.sql
commit;
source ./schema/name_data.tab
source ./data/name_data.sql
commit;
source ./schema/nfl_data.tab
source ./data/nfl_data.sql
commit;
source schema/nfl_stadium_data.tab
source ./data/nfl_stadium_data.sql
commit;
