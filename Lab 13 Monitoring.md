# SQL Server Diagnostic Tools Guide

This guide explains how to download and use the following diagnostic tools in SQL Server:

* `Glenn Berry's Diagnostic Queries`
* `sp_Blitz`
* `sp_WhoIsActive`
* `sp_PressureDetector`
* `sp_HumanEvents`

---

## 🧪 Exercise 1: Monitor and resolve a blocking situation

You will create a blocking situation, find more information about it and then decide which connection to KILL to resolve the situation. Note that KILL shouldn’t be taken lightly, so use with care in real life!

* A tip is to close all query windows first.
* Open 3 query windows in the Adventureworks database. Let’s call them QW1, QW2 and QW3.
* You will work with the Person.Person table.

### In QW1

* Start a transaction
* Update BusinessEntityID = 1, and set FirstName = 'Kenneth'
* Leave this query window open

```sql
BEGIN TRAN
UPDATE Person.Person
SET FirstName = 'Kenneth'
WHERE BusinessEntityID = 1;
-- Don't commit or rollback yet
```

### In QW2 and QW3 (do the same in both)

```sql
SELECT * FROM Person.Person;
```

* Now QW2 and QW3 should be blocked
* Use Activity Monitor to check out the blocking situation
* Which SessionIDs are blocked?
* Which SessionID is the root cause to the blocking situation?
* Use `sp_who` and `sp_who2` to get the same information
* You can also select from `sys.dm_tran_locks` (note: lots of rows, most from XML-related objects)
* Terminate the session which is the root cause
* Verify that QW2 and QW3 now receive data
* Optionally download `sp_whoisactive` (below) and try it out
* Close all query windows

---

## 🗓️ Download and Installation

### 1. Glenn Berry's Diagnostic Queries

**Author:** Glenn Berry
**URL:** [https://glennsqlperformance.com/resources/](https://glennsqlperformance.com/resources/)

**Installation / Usage:**

1. Go to the link above and download the T-SQL script that matches your SQL Server version, e.g., *SQL Server 2019 Diagnostic Information Queries*.
2. Open the script in SSMS.
3. Run the parts you're interested in – you don't need to run everything.

**Sample exercise:**

```sql
-- Find top cached SPs by average CPU time
SELECT TOP(25)
    p.name AS [SP Name],
    qs.total_worker_time / qs.execution_count AS [AvgCPU],
    qs.execution_count,
    qs.total_worker_time,
    qs.last_execution_time
FROM sys.procedures AS p  
INNER JOIN sys.dm_exec_procedure_stats AS qs  
    ON p.[object_id] = qs.[object_id]  
ORDER BY [AvgCPU] DESC;
```

* Load your server with some queries and re-run the script to observe changes.

---

### 2. sp\_Blitz

**Author:** Brent Ozar Unlimited
**URL:** [https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit](https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit)

**Installation:**

1. Click on `sp_Blitz.sql` in the repo.
2. Click "Raw" and copy all contents.
3. Paste into SSMS and execute to install it.

**To run sp\_Blitz:**

```sql
EXEC sp_Blitz;
```

**Exercises:**

* Run `sp_Blitz` immediately after installation to get a full list of issues.
* Try creating a table without a primary key or setting unsafe options like `AUTO_SHRINK`, then re-run `sp_Blitz` to see how it's flagged.

```sql
-- Create a database and enable auto_shrink
CREATE DATABASE shrinkdb;
GO
ALTER DATABASE shrinkdb SET AUTO_SHRINK ON;
GO
USE shrinkdb;
EXEC sp_Blitz;
```

* You should see a Priority 10 warning for "Auto Shrink is Enabled"

---

### 3. sp\_WhoIsActive

**Author:** Adam Machanic
**URL:** [https://github.com/amachanic/sp\_whoisactive](https://github.com/amachanic/sp_whoisactive)

**Installation:**

1. Download and open `sp_WhoIsActive.sql`
2. Copy the contents and execute in SSMS to install

**To run it:**

```sql
EXEC dbo.sp_WhoIsActive;
```

Try this blocking scenario:

```sql
-- In Window 1
BEGIN TRAN
UPDATE Adventureworks.person.person
SET Lastname = 'Jones' WHERE BusinessEntityID = 1;
```

```sql
-- In Window 2
SELECT * FROM Adventureworks.person.person;
```

Then run:

```sql
-- In Window 1
EXEC dbo.sp_WhoIsActive;
```

And clean up:

```sql
ROLLBACK TRAN;
```

---

### 4. sp\_PressureDetector

**Author:** Erik Darling
**URL:** [https://github.com/erikdarlingdata/DarlingData](https://github.com/erikdarlingdata/DarlingData)

**Installation:**

1. Open the folder `sp_PressureDetector` and open `sp_PressureDetector.sql`
2. Copy and paste into SSMS, then run it

**To use it:**

```sql
EXECUTE sp_PressureDetector;
```

---

### 5. sp\_HumanEvents

**Author:** Erik Darling
**URL:** [https://github.com/erikdarlingdata/DarlingData](https://github.com/erikdarlingdata/DarlingData)

**Installation:**

1. Go to the GitHub repo and download the install script in `/sp_HumanEvents/`
2. Run the file in SSMS

**To use it:**

```sql
-- In Window 1
USE Adventureworks;
EXEC dbo.sp_HumanEvents @event_type = 'query', @query_duration_ms = 1, @seconds_sample = 20, @database_name = 'AdventureWorks';
```

```sql
-- In Window 2 (while the above is running)
SELECT * FROM person.person;
```

Go back to Window 1. The query will be captured.

---

## 🧠 Tips

* Run these tools from a DBA or admin database to avoid cluttering production databases
* Use SQL Agent Jobs or custom dashboards to schedule and monitor them regularly
