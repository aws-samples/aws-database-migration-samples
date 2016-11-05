USE master;  
GO  
ALTER DATABASE dms_sample  
   SET RECOVERY FULL;  
GO  
-- Create AdvWorksData and AdvWorksLog logical backup devices.   
USE master  
GO  
EXEC sp_addumpdevice 'disk', 'dms_sample_backup',   
'C:\$(BACKUPDIR)\dms_sample.bak';  
GO  
EXEC sp_addumpdevice 'disk', 'dms_sample_log',   
'C:\$(BACKUPDIR)\dms_sample_log.bak';  
GO  
  
-- Back up the full dms_sample database.  
BACKUP DATABASE dms_sample TO dms_sample_backup;  
GO  
-- Back up the dms_sample log.  
BACKUP LOG dms_sample  
   TO dms_sample_log;  
GO 