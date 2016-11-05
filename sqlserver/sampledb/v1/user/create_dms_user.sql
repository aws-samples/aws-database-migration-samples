
use master
CREATE LOGIN dms_user WITH PASSWORD = 'dms_user', CHECK_POLICY = OFF, DEFAULT_DATABASE = dms_sample;
GO
EXEC master..sp_addsrvrolemember @loginame = N'dms_user', @rolename = N'sysadmin'
GO

Use dms_sample;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'NewAdminName')
BEGIN
    CREATE USER [dms_user] FOR LOGIN [dms_user]
	use dms_sampl
    EXEC sp_addrolemember N'db_owner', N'dms_user'
END;
GO
