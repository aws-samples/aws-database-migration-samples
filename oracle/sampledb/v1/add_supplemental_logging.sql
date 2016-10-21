---------------------------------------------------
-- add table level supplemental logging
--------------------------------------------------

DECLARE
  CURSOR tabcur IS
  SELECT owner, table_name
  FROM   dba_tables
  WHERE owner = 'DMS_SAMPLE';

  stmt VARCHAR2(200);
BEGIN
  FOR trec IN tabcur LOOP
    stmt :=  'alter table ' || trec.owner || '.' || trec.table_name || ' add supplemental log data (primary key) columns';
    EXECUTE IMMEDIATE stmt;
  END LOOP;
END;
/
