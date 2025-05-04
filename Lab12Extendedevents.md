# SQL Server Extended Events - Exercises

## 📘 Overview

This guide walks you through creating and verifying **3 different Extended Events sessions** using SQL Server Management Studio (**SSMS**) — **not using the Wizard**. We make sure to capture **only relevant events**, with **minimal noise**.

---

## 🧪 Exercise 1: Capture Long-Running Queries

### 🎯 Goal:

Track queries that take longer than 5 seconds to execute.

### 🛠️ Steps:

1. In SSMS, go to `Management > Extended Events > Sessions`.
2. Right-click `Sessions` > **New Session**.
3. Name: `LongQueries`
4. Uncheck **Start session at server startup**.
5. On the **Events** page:

   * Click **Add Event**
   * Search for and select `sql_statement_completed`
   * Click **Configure**
   * In **Predicate (Filter)** tab, add:

     * Field: `duration`
     * Operator: `>`
     * Value: `5000000`
   * In **Fields**, deselect everything you don’t need — keep `sql_text`, `duration`, `database_id` etc.
6. Go to **Data Storage** page:

   * Click **Add** > Choose `event_file`
   * Set path, e.g. `C:\XELogs\LongQueries.xel`
7. Save and close the session.
8. Right-click the session > **Start Session**.

### ✅ Verification:

1. Run:

   ```sql
   WAITFOR DELAY '00:00:06';
   ```
2. Right-click the session > **Watch Live Data**.
3. Confirm event shows with duration > 5000000 µs.

---

## 🧪 Exercise 2: Monitor Failed Logins

### 🎯 Goal:

Log failed login attempts only.

### 🛠️ Steps:

1. Create new session: `FailedLogins`
2. On the **Events** page:

   * Add `error_reported`
   * Filter:

     * Field: `error_number` = `18456`
   * In Fields, include `username`, `client_hostname`, and `message`
3. Storage: add an `event_file`, e.g. `C:\XELogs\FailedLogins.xel`
4. Save and start session.

### ✅ Verification:

1. Try to log in with bad credentials.
2. Watch Live Data or open the .xel file.
3. Confirm failed login captured.

---

## 🧪 Exercise 3: Capture Deadlocks

### 🎯 Goal:

Log only actual deadlocks.

### 🛠️ Steps:

1. Create new session: `Deadlocks`
2. Add event: `xml_deadlock_report`
3. No filter needed.
4. Optional: Add fields like `database_name`, `sql_text`
5. Add `event_file`, e.g. `C:\XELogs\Deadlocks.xel`
6. Save and start session.

### ✅ Verification:

1. Simulate a deadlock with two sessions locking rows in reverse order.
2. View captured XML reports in Live Data or file.

---

## 📂 Tip: Viewing .xel Files

You can always right-click on a session and choose **View Target Data** or **Open > File...**

---

Now you're in control — no wizard, no junk. 🔍
