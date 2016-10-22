--
--  Allow 45 minutes for installation (depending on the size of the host)
--
-- 

--------------------------------------------------------
Amazon DMS Sample Database for Oracle: version 1.0

Requirements: Any version of Oracle compatible with DMS
              Approximately 10GB of disk space
              You will need a privileged (DBA) account to execute the scripts

The scripts create users: dms_sample/dms_sample, dms_user/dms_user

Objects are created in the schema: dms_sample


To install create the above accounts and install the associated objects follow the steps in:


IF you are installing the sampledb into an RDS database run the following script from an account that has DBA  privileges (The master account):

install-rds.sql


IF you are installing the sampledb into a NON RDS database run the following script from an account that has DBA  privileges:

install-onprem.sql
