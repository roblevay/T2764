
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

### 2. sp_PressureDetector
**Author:** Erik Darling  
**URL:** [https://github.com/erikdarlingdata/DarlingData](https://github.com/erikdarlingdata/DarlingData)

**Installation:**
```sql
-- Navigate to the GitHub repo and download the install script from /sp_PressureDetector/
:r https://raw.githubusercontent.com/ErikEJ/SQL-Server-Tools/master/sp_PressureDetector.sql
```

### 3. sp_HumanEvents
**Author:** Erik Darling  
**URL:** [https://github.com/erikdarlingdata/DarlingData](https://github.com/erikdarlingdata/DarlingData)

**Installation:**
```sql
-- Navigate to the GitHub repo and download the install script from /sp_HumanEvents/
:r https://raw.githubusercontent.com/ErikEJ/SQL-Server-Tools/master/sp_HumanEvents.sql
```

---

## 🧪 How to Use Them

### ✅ sp_WhoIsActive
Returns a live snapshot of currently executing queries.

```sql
EXEC sp_WhoIsActive;
-- Optional parameters:
EXEC sp_WhoIsActive @get_plans = 1, @get_locks = 1;
```

### ✅ sp_PressureDetector
Identifies bottlenecks in SQL Server, focusing on wait stats and system-level stress.

```sql
EXEC sp_PressureDetector;
```

### ✅ sp_HumanEvents
Wraps around Extended Events and simplifies real-time session troubleshooting.

```sql
EXEC sp_HumanEvents @event_type = 'rpc_completed';
-- Can also trace waits, statements, login/logout events etc.
```

---

## 🧠 Tips

- Always run these tools from a DBA or admin database to avoid cluttering production user databases.
- Use SQL Agent Jobs or custom dashboards to automate regular execution and logging of results.
