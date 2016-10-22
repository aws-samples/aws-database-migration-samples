--------------------------------------------------------
--
-- Create the user dms_sample 
--
--------------------------------------------------------
create user dms_sample identified by dms_sample;
grant CREATE SESSION to dms_sample;
grant resource to dms_sample;
grant create table to dms_sample;
grant create sequence to dms_sample;
grant create procedure to dms_sample;
grant create trigger to dms_sample;
grant create view to dms_sample;
grant create synonym to dms_sample;
grant create public synonym to dms_sample;
grant drop public synonym to dms_sample;
grant execute on dbms_lock to dms_sample;

alter user dms_sample default tablespace users;
alter user dms_sample quota unlimited on users;

alter user dms_sample temporary tablespace temp;

--------------------------------------------------------
--
-- required for the schema conversion tool
--
--------------------------------------------------------
grant select_catalog_role to dms_sample;
grant select any dictionary to dms_sample;
