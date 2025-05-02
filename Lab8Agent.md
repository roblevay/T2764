
# 🧪 SQL Server Agent Jobs – Creating, Scripting, and Using Tokens

## 🎯 Objectives

1. Create a backup job on server `North`.
2. Add an Agent Token to retrieve the job name.
3. Script the job and deploy it to `North\A`.
4. Create a shrink job for `AdventureWorks` on `North`.
5. Add a token to log machine name and job start time.

---

## 🛠️ Step 1 – Create a Backup Job on Server `North`

1. Open SSMS and connect to `North`.
2. Expand **SQL Server Agent** > **Jobs**.
3. Right-click **Jobs** > **New Job**.
4. Name the job: `Backup Adventureworks`.
5. Add a step:
   - Type: Transact-SQL
   - Command:

```sql
BACKUP DATABASE AdventureWorks
TO DISK = 'C:\DemoDatabases\AdventureWorks.bak'
WITH INIT;
```

6. Add a schedule if desired.
7. Click OK to save the job.

---

## 🧪 Step 2 – Add an Agent Token for Job Name

Edit the job step and change the command to include this line for logging:

```sql
PRINT 'Running job: $(ESCAPE_NONE(JOBNAME))';
BACKUP DATABASE AdventureWorks
TO DISK = 'C:\DemoDatabases\AdventureWorks.bak'
WITH INIT;
```

> This token will print the job name when the step runs.

---

## 📄 Step 3 – Script the Job and Deploy to `North\A`

1. In SSMS, right-click the job `Backup Adventureworks`.
2. Choose **Script Job as > CREATE To > New Query Editor Window**.
3. Copy the script.
4. Connect to `North\A`.
5. Run the script to create the same job on `North\A`.

---

## 🔧 Step 4 – Create a Shrink Job on `North`

1. On `North`, create a new job named `Shrink Adventureworks`.
2. Add a step with the following command:

```sql
PRINT 'Shrink operation on $(ESCAPE_NONE(MACHINENAME)) at $(ESCAPE_NONE(STRTDT))';
DBCC SHRINKDATABASE (AdventureWorks);
```

3. Save the job.

---

## 🔍 Explanation of Tokens

- `$(ESCAPE_NONE(JOBNAME))`: Inserts the job name.
- `$(ESCAPE_NONE(MACHINENAME))`: Inserts the machine name.
- `$(ESCAPE_NONE(STRTDT))`: Inserts the job start date and time.

Tokens are automatically replaced at runtime by SQL Server Agent.

---

## ✅ Summary

You now know how to:
- Create and script SQL Server Agent jobs
- Use Agent Tokens for dynamic logging
- Re-deploy jobs to another server

