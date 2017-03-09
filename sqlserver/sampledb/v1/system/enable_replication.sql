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


:setvar DistPubServer @@SERVERNAME


-- This script uses sqlcmd scripting variables. They are in the form
-- $(MyVariable). For information about how to use scripting variables  
-- on the command line and in SQL Server Management Studio, see the 
-- "Executing Replication Scripts" section in the topic
-- "Programming Replication Using System Stored Procedures".

-- Install the Distributor and the distribution database.
DECLARE @distributor AS sysname;
DECLARE @distributionDB AS sysname;
DECLARE @publisher AS sysname;
DECLARE @directory AS nvarchar(500);
DECLARE @publicationDB AS sysname;
-- Specify the Distributor name.
SET @distributor = $(DistPubServer);
-- Specify the distribution database.
SET @distributionDB = N'distribution';
-- Specify the Publisher name.
SET @publisher = $(DistPubServer);
-- Specify the replication working directory.
SET @directory = N'\\' + $(DistPubServer) + '\repldata';
-- Specify the publication database.
SET @publicationDB = N'dms_sample'; 

-- Install the server MYDISTPUB as a Distributor using the defaults,
-- including autogenerating the distributor password.
USE master
EXEC sp_adddistributor @distributor = @distributor;

-- Create a new distribution database using the defaults, including
-- using Windows Authentication.
USE master
EXEC sp_adddistributiondb @database = @distributionDB, 
    @security_mode = 1;
GO

-- Create a Publisher and enable dms_sample for replication.
-- Add MYDISTPUB as a publisher with MYDISTPUB as a local distributor
-- and use Windows Authentication.
DECLARE @distributionDB AS sysname;
DECLARE @publisher AS sysname;
-- Specify the distribution database.
SET @distributionDB = N'distribution';
-- Specify the Publisher name.
SET @publisher = $(DistPubServer);

USE [distribution]
EXEC sp_adddistpublisher @publisher=@publisher, 
    @distribution_db=@distributionDB, 
    @security_mode = 1;
GO 
