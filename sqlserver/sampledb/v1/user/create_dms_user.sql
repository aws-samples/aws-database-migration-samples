/*
 Copyright 2017 Amazon.com

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/



use master
CREATE LOGIN dms_user WITH PASSWORD = 'dms_user', CHECK_POLICY = OFF, DEFAULT_DATABASE = dms_sample;
GO
EXEC master..sp_addsrvrolemember @loginame = N'dms_user', @rolename = N'sysadmin'
GO

Use dms_sample;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'dms_user')
BEGIN
    CREATE USER [dms_user] FOR LOGIN [dms_user]
	use dms_sample
    EXEC sp_addrolemember N'db_owner', N'dms_user'
END;
GO
