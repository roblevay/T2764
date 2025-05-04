
# SQL Server Diagnostic Tools Guide

This guide explains how to download and use the following diagnostic tools in SQL Server:

- `sp_WhoIsActive`
- `sp_PressureDetector`
- `sp_HumanEvents`

---

## 📥 Download and Installation

### 1. sp_WhoIsActive
**Author:** Adam Machanic  
**URL:** [https://github.com/amachanic/sp_whoisactive](https://github.com/amachanic/sp_whoisactive)

**Installation:**
Open the file sp_WhoIsActive.sql

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

### 2. sp_PressureDetector
**Author:** Erik Darling  
**URL:** [https://github.com/erikdarlingdata/DarlingData](https://github.com/erikdarlingdata/DarlingData)

**Installation:**

1. Open the folder sp_PressureDetector and then open the file sp_PressureDetector.sql
2. Copy the content of the file and paste it in ssms
3. Run the file

To run sp_PressureDetector:

```sql
EXECUTE sp_PressureDetector
```


### 3. sp_HumanEvents
**Author:** Erik Darling  
**URL:** [https://github.com/erikdarlingdata/DarlingData](https://github.com/erikdarlingdata/DarlingData)

**Installation:**

1. Navigate to the GitHub repo and download the install script from /sp_HumanEvents/
2. Run the file

To run sp_HumanEvents:

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


---

## 🧠 Tips

- Always run these tools from a DBA or admin database to avoid cluttering production user databases.
- Use SQL Agent Jobs or custom dashboards to automate regular execution and logging of results.
