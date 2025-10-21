USE [master]
ALTER DATABASE Adventureworks SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO

RESTORE DATABASE [AdventureWorks] FROM  
DISK = N'C:\Dbfiles\AdventureWorks2016.bak' WITH  FILE = 1,  
MOVE N'AdventureWorks2016_Data' 
TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\AdventureWorks_Data.mdf',  
MOVE N'AdventureWorks2016_Log' 
TO N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\AdventureWorks_Log.ldf',  NOUNLOAD,  REPLACE,  STATS = 5

GO
