print('Removing database dms_sample and login dms_user...')
go

PRINT(CONCAT('Start: ',CURRENT_TIMESTAMP));
GO

print('Removing replication...')
go

USE [dms_sample]
EXEC sp_removedbreplication @dbname=[dms_sample]
GO

print('Removing jobs...')
go

USE msdb
BEGIN TRY
  DECLARE @jid VARCHAR(200);
  DECLARE @J_CUR CURSOR;
  SET @J_CUR = CURSOR FOR 
    SELECT  s.job_id
    FROM    msdb..sysjobs s 
    WHERE SUSER_SNAME(s.owner_sid) = 'dms_user';

  OPEN @J_CUR;
  FETCH @J_CUR INTO @jid;
  WHILE @@FETCH_STATUS = 0 
    BEGIN
	  EXEC sp_delete_job @job_id = @jid;
	  FETCH @J_CUR INTO @jid;
	END;
	PRINT('All jobs owned by dms_user have been deleted...')
END TRY
BEGIN CATCH
  PRINT('ERROR: Unable to delete all jobs..')
END CATCH;
go

Print('Removing user: dms_user...')
GO

USE dms_sample;
drop user dms_user;
go

Print('Removing database: dms_sample...')
GO

USE master;
ALTER DATABASE dms_sample SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE dms_sample;
go

Print('Removing login: dms_user...')
GO

drop login dms_user;
go

Print('Removing dms_sample backup devices...')
EXEC sp_dropdevice 'dms_sample_backup';
EXEC sp_dropdevice 'dms_sample_log';


PRINT(CONCAT('Complete: ',CURRENT_TIMESTAMP));
GO

Print('.....   Done   .....')
GO
