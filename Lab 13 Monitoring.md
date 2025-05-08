# SQL Server Diagnostic Tools Guide

This guide explains how to download and use the following diagnostic tools in SQL Server:

* `Glenn Berry's Diagnostic Queries`
* `sp_Blitz`
* `sp_WhoIsActive`
* `sp_PressureDetector`
* `sp_HumanEvents`

---

## 📅 Download and Installation

### 1. Glenn Berry's Diagnostic Queries

**Author:** Glenn Berry
**URL:** [https://glennsqlperformance.com/resources/](https://glennsqlperformance.com/resources/)

**Installation / Usage:**

1. Gå till länken ovan och ladda ner det T-SQL-script som passar din version av SQL Server, t.ex. *SQL Server 2019 Diagnostic Information Queries*.
2. Öppna scriptet i SSMS.
3. Kör de delar du är intresserad av – du behöver inte köra allt samtidigt.

**Tips på övningar:**

* Kör frågorna enskilt och notera vad de visar. T.ex. för att kolla CPU-förbrukning:

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

* Testa att belasta servern lite (t.ex. med en loopad SELECT eller JOIN) och kör scriptet igen för att se hur statistik förändras.

---

### 2. sp\_Blitz

**Author:** Brent Ozar Unlimited
**URL:** [https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit](https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit)

**Installation:**

1. Klicka på sp_blitz
2. Klicka på Copy raw file
3. Klistra in scriptet i ssms och kör det.

För att köra sp\_Blitz:

```sql
EXEC sp_Blitz;
```

**Övningar:**

* Kör `sp_Blitz` direkt efter installation – du får en lång lista med potentiella problem eller saker att tänka på.
* Testa att skapa en tabell utan primärnyckel, eller kör en query med `NOLOCK`, och kör `sp_Blitz` igen för att se om det fångas.
* Kör med olika parametrar, t.ex.:

```sql
-- Kör bara checks relaterade till performance
EXEC sp_Blitz @CheckServerInfo = 0, @OutputType = 'TABLE';
```

* Skapa ett temporärt test-scenario:

```sql
-- Skapa en table utan PK och sätt in lite data
CREATE TABLE dbo.TempBlitzTest (Id INT, Name NVARCHAR(50))
INSERT INTO dbo.TempBlitzTest VALUES (1, 'Test')

-- Kör sp_Blitz och notera varningen om saknad PK
EXEC sp_Blitz
```

---

### 3. sp\_WhoIsActive

**Author:** Adam Machanic
**URL:** [https://github.com/amachanic/sp\_whoisactive](https://github.com/amachanic/sp_whoisactive)

**Installation:**
Open the file sp\_WhoIsActive.sql

Copy the content and run the file in sql server

To run the tool:

```sql
EXEC dbo.sp_WhoIsActive
```

The tool will not show so much when there are no blockings. Try this:

```sql
--Do this in Window 1
BEGIN TRAN
UPDATE Adventureworks.person.person
SET Lastname='Jones' WHERE BusinessEntityID=1
```

```sql
--Do this in Window 2
SELECT * FROM Adventureworks.person.person
```

Now run the tool in Windows 1:

```sql
EXEC dbo.sp_WhoIsActive
```

Do not forget to rollback the transaction:

```sql
--Windows 1
ROLLBACK TRAN
```

---

### 4. sp\_PressureDetector

**Author:** Erik Darling
**URL:** [https://github.com/erikdarlingdata/DarlingData](https://github.com/erikdarlingdata/DarlingData)

**Installation:**

1. Open the folder sp\_PressureDetector and then open the file sp\_PressureDetector.sql
2. Copy the content of the file and paste it in ssms
3. Run the file

To run sp\_PressureDetector:

```sql
EXECUTE sp_PressureDetector
```

---

### 5. sp\_HumanEvents

**Author:** Erik Darling
**URL:** [https://github.com/erikdarlingdata/DarlingData](https://github.com/erikdarlingdata/DarlingData)

**Installation:**

1. Navigate to the GitHub repo and download the install script from /sp\_HumanEvents/
2. Run the file

To run sp\_HumanEvents:

```sql
--In window 1
USE Adventureworks
EXEC dbo.sp_HumanEvents @event_type = 'query', @query_duration_ms = 1, @seconds_sample = 20, @database_name = 'AdventureWorks';
```

```sql
--In window 2, while the query in window 1 is running
USE Adventureworks
SELECT * FROM person.personSELEC
```

Return to window 1. The query will have been captured since it took more than 1 ms

---

## 🧠 Tips

* Always run these tools from a DBA or admin database to avoid cluttering production user databases.
* Use SQL Agent Jobs or custom dashboards to automate regular execution and logging of results.
