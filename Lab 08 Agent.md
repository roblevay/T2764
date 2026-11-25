
# 🧪 SQL Server Agent Jobs – Creating, Scripting, and Using Tokens

## Start
Create a folder called c:\DemoDatabases

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

Edit the job step 
Click Advanced
At output file, type C:\DemoDatabases\\$(ESCAPE_NONE(MACHINENAME))_$(ESCAPE_NONE(JOBNAME))_$(ESCAPE_NONE(STRTDT)).txt



 This token will create a file with the machine name, job name and date and time when the job is run

---

## 📄 Step 3 – Script the Job and Deploy to `North\A` (If it exists, otherwise on the same server)

1. In SSMS, right-click the job `Backup Adventureworks`.
2. Choose **Script Job as > CREATE To > New Query Editor Window**.
3. Copy the script.
4. Connect to `North\A`.
5. Run the script to create the same job on `North\A`.

---

## 🔧 Step 4 – Create a Shrink Job on `North`

1. On `North`, right-click the Adventureworks database and select Task...Shrink database
2. From the Script menu, select Script action to job
3. Use the name Shrink Database Adventureworks
4. Click OK
5. Click Cancel so that the database is not shrunk right now


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

- Följande värden för kryptering finns:

0: SSL är inaktiverat.
1: SSL är aktiverat.
2: SSL är aktiverat med en FIPS-certifierad krypteringsalgoritm.
Om du vill ändra det, här är hur du gör det:

Starta regedit (Registret Editor).
Navigera till Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL15.MSSQLSERVER\SQLServerAgent\MsxEncryptChannelOptions
Högerklicka på nyckeln och välj Modify.
Ändra värdet till 0 för att inaktivera SSL, eller det värde som är lämpligt för din situation.
Starta om SQL Server Agent för att ändringarna ska träda i kraft.

