DECLARE
  CURSOR tabcur IS
  SELECT  table_name
  FROM   user_tables;
BEGIN
  FOR trec IN tabcur LOOP
   EXECUTE IMMEDIATE 'grant select on dms_sample.' || trec.table_name || ' to DMS_USER';
   EXECUTE IMMEDIATE 'grant alter on dms_sample.'  || trec.table_name || ' to DMS_USER';

  END LOOP;
END;
/



grant execute on ticketManagement to dms_user;
create or replace public synonym ticketmanagement for dms_sample.ticketmanagement;
