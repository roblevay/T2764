# Exercise 1: DBCC CHECKDB

## Step 1 – Run DBCC CHECKDB

### Instructions
Create the folder c:\T2765_Labfiles
Download the file CorruptTsql.bak from the [Files](https://github.com/roblevay/T2765/tree/main/Files)  folder in Github to the newly created folder c:\T2765_Labfiles


1. Restore the `CorruptTsql` database on the default instance using this command:

```sql
RESTORE DATABASE CorruptTsql
FROM DISK = 'c:\T2765_Labfiles\CorruptTsql.bak'
WITH
MOVE 'CorruptTsql' TO 'C:\DbFiles\MsSqlServer\CorruptTsql.mdf',
MOVE 'CorruptTsql_log' TO 'C:\DbFiles\MsSqlServer\CorruptTsql_log.ldf';
```

2. Run `DBCC CHECKDB` on that database and determine if the problem can be repaired **without losing data**.
3. If time permits, try to determine which table and index the corruption affects.
4. Try selecting all rows from the corrupt table and observe the error message.
5. Check if the corrupt pages are listed in the `msdb.dbo.suspect_pages` table.

---

### Answer Suggestion

**Restore the database:**
```sql
USE master
RESTORE DATABASE CorruptTsql
FROM DISK = 'c:\T2765_Labfiles\CorruptTsql.bak'
WITH
MOVE 'CorruptTsql' TO 'C:\DbFiles\MsSqlServer\CorruptTsql.mdf',
MOVE 'CorruptTsql_log' TO 'C:\DbFiles\MsSqlServer\CorruptTsql_log.ldf';
GO
```

**Run DBCC CHECKDB:**
```sql
DBCC CHECKDB(CorruptTsql);
-- or
DBCC CHECKDB(CorruptTsql) WITH NO_INFOMSGS;
```

**Identify the corrupt table using object_id:**
```sql
DECLARE @table_id int = 581577110;
SELECT
    OBJECT_SCHEMA_NAME(@table_id, DB_ID('CorruptTsql')),
    OBJECT_NAME(@table_id, DB_ID('CorruptTsql'));
```

**Try selecting from the corrupt table:**
```sql
SELECT * FROM CorruptTSql.dbo.customers;
```

**Check suspect pages:**
```sql
SELECT * FROM msdb.dbo.suspect_pages;
```
Det ger förmodligen inget resultat. 

Testa istället

```sql
DBCC CHECKTABLE('CorruptTsql.dbo.Customers') WITH ALL_ERRORMSGS, NO_INFOMSGS;
```
Detta ska ge resultat:

För att testa att reparera utan dataförlust

```tsql
ALTER DATABASE CorruptTsql SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DBCC CHECKDB(CorruptTsql,REPAIR_REBUILD)  WITH NO_INFOMSGS;
```
Fungerar nog inte så testa

```tsql
ALTER DATABASE CorruptTsql SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DBCC CHECKDB(CorruptTsql,REPAIR_ALLOW_DATA_LOSS )  WITH NO_INFOMSGS;
```

Den kan behöva köras några gånger men nu är nog tabellen Customers tom...

```tsql
ALTER DATABASE CorruptTsql SET MULTI_USER WITH ROLLBACK IMMEDIATE
SELECT * FROM CorruptTSql.dbo.customers
```


---



# Exercise 2: SQL Server Index Fragmentation & Statistics Exercise

## 🏁 Step 1: Create test database and table

```sql
CREATE DATABASE FragDemo;
GO

USE FragDemo;
GO

DROP TABLE IF EXISTS Test;
GO

CREATE TABLE Test (
    ID INT IDENTITY PRIMARY KEY,
    Value CHAR(800)  -- Large rows to use up more space per page
);
GO
```

---

## 🧱 Step 2: Create index with low fill factor

```sql
CREATE NONCLUSTERED INDEX IX_Test_Value 
ON Test(Value)
WITH (FILLFACTOR = 70);
GO
```

---

## 📥 Step 3: Insert rows to fill pages

```sql
INSERT INTO Test (Value)
VALUES (REPLICATE('A', 800));
GO 2000
```

---

## 🗑️ Step 4: Delete a portion of the data

```sql
DELETE FROM Test WHERE ID % 3 = 0;
```

---

## 🔁 Step 5: Insert more rows to cause fragmentation

```sql
INSERT INTO Test (Value)
VALUES (REPLICATE('B', 800));
GO 1000
```

---

## 🔍 Step 6: Check fragmentation

```sql
SELECT 
    index_type_desc,
    avg_fragmentation_in_percent,
    fragment_count,
    avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID('Test'), NULL, NULL, NULL);
```

---

## 🧹 Step 7: Reorganize and Rebuild

### Reorganize (lighter operation)

```sql
ALTER INDEX IX_Test_Value ON Test REORGANIZE;
```

### Rebuild (heavier, but more effective)

```sql
ALTER INDEX IX_Test_Value ON Test REBUILD;
```

---

## 📊 Step 8: Update statistics

### A. Update statistics for a specific table

```sql
UPDATE STATISTICS Test;
```

### B. Update a specific index/statistics object

```sql
UPDATE STATISTICS Test IX_Test_Value;
```

### C. Update all statistics in the database

```sql
EXEC sp_updatestats;
```

---

## ✅ Done!

You've now learned how to:
- Create a table and index
- Cause and detect fragmentation
- Reorganize or rebuild indexes
- Update statistics (per table and entire DB)

&nbsp;

&nbsp;



# 🛠️ Exercise 3: SQL Server Maintenance Plans – Step-by-Step Exercise

## 🎯 Objective

Create three separate maintenance plans in SQL Server using SQL Server Management Studio (SSMS) to:

1. Back up all user databases.
2. Perform database maintenance (index rebuild/reorganize and update statistics).
3. Clean up old backup files and maintenance history.

---

## 🧩 Prerequisites

- SQL Server Agent must be running.
- SSMS installed and connected to an instance.
- Sufficient permissions to create maintenance plans (typically sysadmin).

---

## 🔹 Plan 1: Back Up All User Databases

### Step-by-Step:

1. Open **SSMS** and connect to your SQL Server instance.
2. Expand **Management** > Right-click **Maintenance Plans** > Choose **New Maintenance Plan**.
3. Name the plan: `UserDatabaseBackup`. Wait for some time for the toolbox Maintenance Plan Tasks to appear in the upper left corner.
4. In the toolbox (on the left), drag **Back Up Database Task** into the designer.
5. Double-click the task to configure:
   - **Backup type**: Full
   - **Databases**: All user databases
   - **Backup to**: Choose location (e.g. `C:\SQLBackups`)
   - Enable backup compression if supported
   - Optional: Create a sub-directory for each database
6. Click **OK**.
7. Click on the Add Subplan icon 
   - Name: `NightlyBackup`
   - Add a Schedule
   - Frequency: Daily
   - Time: e.g. 2:00 AM
If more than one subplan appear, select the ones you don't want and click Delete Selected Subplan. 
     
8. Save the plan (Ctrl+S or File > Save)
9. Execute the plan and verify that the backup files are created

---

## 🔹 Plan 2: Index and Statistics Maintenance

### Step-by-Step:

1. Right-click **Maintenance Plans** > **New Maintenance Plan**.
2. Name the plan: `IndexAndStatsMaintenance`.
3. Add **Rebuild Index Task**:
   - Databases: All user databases
   - Tables: All tables
4. Add **Update Statistics Task**:
   - Databases: All user databases
   - Scan type: Full scan 
5. Schedule the plan:
   - Frequency: Weekly
   - Time: e.g. Sunday at 3:00 AM
6. Save the plan.

---

## 🔹 Plan 3: Cleanup Old Backups and History

### Step-by-Step:

1. Create a new maintenance plan: `CleanupTasks`.
2. Add **Maintenance Cleanup Task**:
   - Delete: Backup files
   - Folder: Same as used in the backup plan (`C:\SQLBackups`)
   - File extension: `.bak`
   - File age: Delete files older than 7 days
3. Add another **Maintenance Cleanup Task**:
   - Delete: Maintenance Plan history
   - File age: Older than 30 days
4. Schedule:
   - Frequency: Weekly
   - Time: e.g. Sunday at 4:00 AM
5. Save the plan.

---

## ✅ Summary

This set of exercises helps automate key SQL Server maintenance:

- **Plan 1** ensures all databases are backed up nightly.
- **Plan 2** keeps indexes and stats optimized weekly.
- **Plan 3** prevents disk space and history buildup.

All can be created without writing T-SQL using the Maintenance Plan Wizard or Designer in SSMS.

If time permits, verify that the Sql Server Agent service is running and execute each of the plans by right-clicking and verifying that they run correctly.

&nbsp;

&nbsp;


# 🔧 Exercise 4: Using Ola Hallengren’s SQL Server Maintenance Solution

## 🎯 Objective

Set up Ola Hallengren’s widely used maintenance scripts to:

- Back up all user databases
- Perform index maintenance (rebuild if > 30% fragmentation, reorganize if 10–30%)
- Update statistics

---

## 📥 Step 1 – Download the Scripts

1. Go to the official website (right-click to open in new tab):  
   👉 <a href="https://ola.hallengren.com" target="_blank">https://ola.hallengren.com</a>

2. Click  “MaintenanceSolution.sql” under Getting Started

3. Open **SQL Server Management Studio (SSMS)** and run the downloaded script against the **master** database.

   This will create:
   - Stored procedures (e.g., `dbo.DatabaseBackup`, `dbo.IndexOptimize`)
   - Support tables (e.g., `dbo.CommandLog`)
  

---

## 🧪 Step 2 – Run Backup for All User Databases

To back up all user databases to a folder (e.g., `C:\SQLBackups`):

```sql
EXEC dbo.DatabaseBackup
  @Databases = 'USER_DATABASES',
  @Directory = 'C:\SQLBackups',
  @BackupType = 'FULL',
  @Compress = 'Y',
  @CheckSum = 'Y',
  @LogToTable='Y';
```

You can schedule this using a SQL Agent job that runs nightly.

---






## 🔧 Step 3 – Index Maintenance

To rebuild/reorganize indexes based on fragmentation:

```sql
EXEC dbo.IndexOptimize
  @Databases = 'USER_DATABASES',
  @FragmentationLow = NULL,
  @FragmentationMedium = 'INDEX_REORGANIZE',
  @FragmentationHigh = 'INDEX_REBUILD_ONLINE',
  @FragmentationLevel1 = 10,
  @FragmentationLevel2 = 30,
  @UpdateStatistics = 'ALL',
  @LogToTable='Y';
```

- Reorganize if fragmentation is **10–30%**
- Rebuild if **>30%**
- Also updates statistics for all indexes

Schedule this weekly or as needed using SQL Agent.

---

## 🗂️ Optional: Command Log Table

You can review what actions were taken by querying:

```sql
SELECT * FROM dbo.CommandLog ORDER BY StartTime DESC;
```

---

## ✅ Summary

With minimal setup, Ola Hallengren’s solution gives you:

- Reliable backups with checksums and compression
- Smart index and stats maintenance based on actual fragmentation
- Logging of all maintenance actions

Perfect for both small environments and enterprise-scale SQL Servers.


