USE dms_sample;
drop user dms_user;
go

USE master;
ALTER DATABASE dms_sample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE dms_sample;
go

drop login dms_user;
go

EXEC sp_dropdevice 'dms_sample_backup';


EXEC sp_dropdevice 'dms_sample_log';


