# SQL Server Extended Events - Exercises

## 📘 Overview

This exercise guide walks you through creating and verifying **3 different Extended Events** sessions using SQL Server Management Studio (SSMS). Each task uses the **graphical interface** and includes a verification step.

---

## 🧪 Exercise 1: Capture Long-Running Queries

### 🎯 Goal:

Track queries that take longer than 5 seconds to execute.

### 🛠️ Steps:

1. Open **SSMS** and connect to your SQL Server instance.
2. Expand `Management` > expand `Extended Events` > right-click `Sessions` > choose **New Session Wizard**.
3. Click **Next** > Name the session `LongQueries`.
4. Select **Do not use a template** > click **Next**.
5. In **Events Selection**, check `sql_statement_completed` and click `>`
6. Click **Next**
7. In the Capture Global Fields window, click **Next**
10. Click **Next**.
11. For **Specify Session Data Storage**, select:
12.  `Save to file` (choose folder like `C:\XELogs\LongQueries.xel`)
11. Click **Finish** to create the session.
12. Right-click the session > **Start Session**.

### ✅ Verification:

1. Run this query in another SSMS window:

   ```sql
   WAITFOR DELAY '00:00:06';
   ```
2. Go back to your XE session, right-click > **Watch Live Data**.
3. Confirm the event appears in the live data view.

---

## 🧪 Exercise 2: Monitor Failed Logins

### 🎯 Goal:

Capture login failures to the SQL Server.

### 🛠️ Steps:

1. New Session Wizard > Name: `FailedLogins`.
2. No template > Click **Next**.
3. Event Selection:

   * Add `error_reported` event.
4. Configure > Filters:

   * Field: `error_number`
   * Operator: `=`
   * Value: `18456`
5. Store data to file: `C:\XELogs\FailedLogins.xel`
6. Finish and start the session.

### ✅ Verification:

1. In a different SSMS or using SQLCMD, try logging in with wrong credentials.
2. Watch Live Data for `FailedLogins` session — the event should appear.

---

## 🧪 Exercise 3: Capture Deadlocks

### 🎯 Goal:

Track deadlocks in your SQL Server.

### 🛠️ Steps:

1. New Session Wizard > Name: `Deadlocks`.
2. No template > Next.
3. Event Selection:

   * Add `xml_deadlock_report`
4. No filter needed.
5. Output to file: `C:\XELogs\Deadlocks.xel`
6. Finish and start the session.

### ✅ Verification:

1. Use a deadlock script from the internet or training material to simulate a deadlock.
2. Watch Live Data and check for the `xml_deadlock_report` event.

---

## 📂 Tip: Reading .xel Files Later

You can open `.xel` files by right-clicking on `Extended Events > Sessions`, then choosing **"Open > File..."**.

---

Happy tracing! 🕵️‍♂️

