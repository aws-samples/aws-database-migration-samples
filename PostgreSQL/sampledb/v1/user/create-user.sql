create user dms_user with password 'dms_user';
GRANT ALL PRIVILEGES ON                  SCHEMA dms_sample TO dms_user;
GRANT ALL PRIVILEGES ON ALL TABLES    IN SCHEMA dms_sample TO dms_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA dms_sample TO dms_user;
