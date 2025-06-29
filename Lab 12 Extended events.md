# SQL Server Extended Events - Exercises

## 📘 Overview

This guide walks you through creating and verifying **3 different Extended Events sessions** using SQL Server Management Studio (**SSMS**) — **not using the Wizard**. We make sure to capture **only relevant events**, with **minimal noise**.

---

## 🧪 Exercise 1: Capture Long-Running Queries

### 🎯 Goal:

Track queries that take longer than 5 seconds to execute.

If the folder C:\XELogs does not exist, create it!

### 🛠️ Steps:

1. In SSMS, go to `Management > Extended Events > Sessions`.
2. Right-click `Sessions` > **New Session**.
3. Name: `LongQueries`
4. Uncheck **Start session at server startup**.
5. On the **Events** page:

   * Search for and select `sql_statement_completed`
   * Click `>`
   * Click **Configure**
   * In **Filter (Predicate) ** tab, add:

     * Field: `duration`
     * Operator: `>`
     * Value: `5000000`
   * In **Global Fields(Actions)**, select  `sql_text`, `database_name`, `client_app_name` 
6. Go to **Data Storage** page:

   * Click **Add** > Choose `event_file`
   * Set path, e.g. `C:\XELogs\LongQueries.xel`
7. Save and close the session.
8. Right-click the session > **Start Session**.

### ✅ Verification:

1. 2. Right-click the session > **Watch Live Data**.
2. Run:

   ```sql
   WAITFOR DELAY '00:00:06';
   ```

3. Confirm event shows with duration > 5000000 µs, that is more than 5 seconds

---

## 🧪 Exercise 2: Monitor Failed Logins

### 🎯 Goal:

Log failed login attempts only.

### 🛠️ Steps:

1. Create new session: `FailedLogins`
2. On the **Events** page:

   * Add `error_reported` from the Admin Channel
   * Filter:

     * Field: `error_number` = `18456`
   * In Fields, include `client_hostname`
3. Storage: add an `event_file`, e.g. `C:\XELogs\FailedLogins.xel`
4. Save and start session.

### ✅ Verification:

1. Right-click the session and select Watch Live Data
2. Try to log in with bad credentials.
3. Watch Live Data or open the .xel file.
4. Confirm failed login captured.

---

## 🧪 Exercise 3: Capture Deadlocks

### 🎯 Goal:

Log only actual deadlocks.

### 🛠️ Steps:

1. Create new session: `Deadlocks`
2. Add event: `xml_deadlock_report`
3. No filter needed.
4. Add the fields  `database_name`, `sql_text`
5. Add `event_file`, e.g. `C:\XELogs\Deadlocks.xel`
6. Save and start session.



### 🧪 Test the session: Simulate a Deadlock

#### 1. Create test table
```sql
USE tempdb
DROP TABLE IF EXISTS DeadlockTest;
CREATE TABLE DeadlockTest (
    ID INT PRIMARY KEY,
    Value VARCHAR(100)
);

INSERT INTO DeadlockTest (ID, Value)
VALUES (1, 'First'), (2, 'Second');
````

#### 2. Open **two separate SSMS query windows** — Session A and Session B. Run both queries within 10 seconds

---

### 🪩 Session A

```sql
--Run this first
USE Tempdb
BEGIN TRAN;
UPDATE DeadlockTest SET Value = 'A1' WHERE ID = 1;
-- Wait here to simulate overlap
WAITFOR DELAY '00:00:10';
UPDATE DeadlockTest SET Value = 'A2' WHERE ID = 2;
COMMIT;
```

---

### 🪩 Session B

```sql
--then this
USE Tempdb
BEGIN TRAN;
UPDATE DeadlockTest SET Value = 'B1' WHERE ID = 2;
-- Wait to collide with A
WAITFOR DELAY '00:00:10';
UPDATE DeadlockTest SET Value = 'B2' WHERE ID = 1;
COMMIT;
```

---

### ✅ Result

One of the sessions will be chosen as the deadlock victim and get an error:

```
Transaction (Process ID xx) was deadlocked on resources with another process and has been chosen as the deadlock victim.
```

You can catch this using the `xml_deadlock_report` Extended Event.

In the Live data window, double-click on the xml report to expand it




---

## 📂 Tip: Viewing .xel Files

You can always right-click on a session and choose **View Target Data** or **Open > File...**

---
