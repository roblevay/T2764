USE master
GO

IF OBJECT_ID('sp_dbinfo') IS NOT NULL DROP PROC sp_dbinfo
GO

CREATE PROC sp_dbinfo
 @sort char(1) = 'n'
,@include_instance_name char(1) = 'n'
AS
/***************************************************************************
@sort accept 4 values: 'n' (default), 'd', 'l' and 'r'.
@include_server_name accept 2 values, 'y' and 'n'.
It specifies the sort order (name, data allocated, log allocated, rollup only).

Written by Tibor Karaszi 2009-12-29
Modified 2010-01-19, fixed data type for db name. Thanks csm!
Modified 2010-05-24, added support for offline databases. Thanks Per-Ivan N?und.
Modified 2011-07-21, SQL Server 11, use sysperfinfo instead of DBCC SQLPERF.
Modified 2011-09-23, master instead of MASTER, also qualified sysperfinfo.
Modified 2011-12-28, renamed to sp_dbinfo, added rollup option.
Modified 2013-02-19, added recovery model and option for instance name.
Modified 2014-10-14, addressed bug that it sometimes only reported for master
                     (changed cursor over sys.databases to STATIC).
***************************************************************************/ 
SET NOCOUNT ON
DECLARE
 @sql nvarchar(2000)
,@db_name sysname
,@recovery_model varchar(12)
,@crlf char(2)

SET @crlf = CHAR(13) + CHAR(10)

--Create tables to hold space usage stats from commands
CREATE TABLE #logspace
(
 database_name sysname NOT NULL
,log_size real NOT NULL
,log_percentage_used real NOT NULL
)

CREATE TABLE #dbcc_showfilestats
(
 database_name sysname NULL
,file_id_ int NOT NULL
,file_group int NOT NULL
,total_extents bigint NOT NULL
,used_extents bigint NOT NULL
,name_ sysname NOT NULL
,file_name_ nvarchar(3000) NOT NULL
)

--Create table to hold final output
CREATE TABLE #final_output
(
 database_name sysname
,data_allocated int
,data_used int
,log_allocated int
,log_used int
,is_sum bit
)

--Populate log space usage
INSERT INTO #logspace(database_name, log_size, log_percentage_used)
SELECT
instance_name AS 'Database Name'
,MAX(CASE
     WHEN counter_name = 'Log File(s) Size (KB)' THEN cntr_value / 1024.
     ELSE 0
    END) AS 'Log Size (MB)'
,MAX(CASE
      WHEN counter_name = 'Percent Log Used' THEN cntr_value
      ELSE 0
     END) AS 'Log Space Used (%)'
FROM master..sysperfinfo
WHERE counter_name IN('Log File(s) Size (KB)', 'Percent Log Used')
AND instance_name != '_total'
GROUP BY instance_name

----Populate data space usage 
DECLARE db CURSOR STATIC FOR SELECT name FROM sys.databases WHERE state_desc = 'ONLINE'
OPEN db
WHILE 1 = 1
BEGIN
FETCH NEXT FROM db INTO @db_name
IF @@FETCH_STATUS <> 0
BREAK
SET @sql = 'USE ' + QUOTENAME(@db_name) + ' DBCC SHOWFILESTATS WITH NO_INFOMSGS'
INSERT INTO #dbcc_showfilestats(file_id_, file_group, total_extents, used_extents, name_, file_name_)
EXEC (@sql)
UPDATE #dbcc_showfilestats SET database_name = @db_name WHERE database_name IS NULL
END
CLOSE db
DEALLOCATE db

--Result into final table
INSERT INTO #final_output(database_name, data_allocated, data_used, log_allocated, log_used, is_sum)
SELECT
CASE WHEN d.database_name IS NOT NULL THEN d.database_name ELSE '[ALL]' END AS database_name
,ROUND(SUM(CAST((d.data_alloc * 64.00) / 1024 AS DECIMAL(18,2))), 0) AS data_allocated
,ROUND(SUM(CAST((d.data_used * 64.00) / 1024 AS DECIMAL(18,2))), 0) AS data_used
,ROUND(SUM(CAST(log_size AS numeric(18,2))), 0) AS log_allocated
,ROUND(SUM(CAST(log_percentage_used * 0.01 * log_size AS numeric(18,2))), 0) AS log_used
,GROUPING(d.database_name) AS is_sum
FROM
(
SELECT database_name, SUM(total_extents) AS data_alloc, SUM(used_extents) AS data_used
FROM #dbcc_showfilestats
GROUP BY database_name
) AS d
INNER JOIN #logspace AS l ON d.database_name = l.database_name
INNER JOIN sys.databases AS sd ON d.database_name = sd.name
GROUP BY d.database_name WITH ROLLUP

--Output result
SET @sql = '
SELECT f.database_name, f.data_allocated, f.data_used, f.log_allocated, f.log_used, d.recovery_model_desc' +
CASE @include_instance_name WHEN 'y' THEN ', @@SERVERNAME AS instance_name' ELSE '' END + @crlf +
'FROM #final_output AS f LEFT OUTER JOIN sys.databases AS d ON f.database_name = d.name' + @crlf +
CASE WHEN @sort = 'r' THEN 'WHERE f.database_name = ''[ALL]''' ELSE '' END + @crlf +
'ORDER BY is_sum' + @crlf +
CASE
   WHEN @sort = 'n' THEN ', database_name'
   WHEN @sort = 'd' THEN ', data_allocated DESC'
   WHEN @sort = 'l' THEN ', log_allocated DESC'
   ELSE ''
 END

--PRINT @sql
EXEC(@sql)

--Test execution
/*
EXEC sp_dbinfo
EXEC sp_dbinfo 'n'
EXEC sp_dbinfo 'd'
EXEC sp_dbinfo 'l'
EXEC sp_dbinfo 'r'
EXEC sp_dbinfo 'n', 'y'
EXEC sp_dbinfo 'd', 'y'
*/
GO
EXEC sp_MS_marksystemobject 'sp_dbinfo'
