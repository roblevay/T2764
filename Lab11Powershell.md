
# 🧪 PowerShell Exercise – Scripting SQL Server Discovery

## 🎯 Objective

Learn how to:
1. Create a folder and PowerShell scripts manually.
2. Display file system content.
3. Query SQL Server for metadata (databases, jobs, logins, users).
4. Use PowerShell ISE to edit scripts.
5. Output results to screen and to a CSV file.

---

## 📁 Step 1 – Create Folder and First Script

1. Open a command prompt or PowerShell.
2. Create a folder:

```powershell
mkdir C:\Pshell
```

3. Open Notepad to create a script:

```powershell
notepad C:\Pshell\ShowContent.ps1
```

4. Paste the following code into the file:

```powershell
Get-ChildItem C:\Pshell
```

5. Save and close the file.

6. Run the script in PowerShell:

```powershell
C:\Pshell\ShowContent.ps1
```

---

## 📦 Step 2 – Create a Script to Show SQL Server Databases

1. Open Notepad again:

```powershell
notepad C:\Pshell\ShowDatabases.ps1
```

2. Paste this basic SQL discovery script:

```powershell
Invoke-Sqlcmd -Query "SELECT name FROM sys.databases" -ServerInstance "localhost"
```

3. Save and close.

4. Test the script in PowerShell:

```powershell
C:\Pshell\ShowDatabases.ps1
```

> 📝 Note: Requires `SqlServer` module. Install with:  
> `Install-Module -Name SqlServer -Scope CurrentUser`

---

## 🧑‍💻 Step 3 – Modify Script Using PowerShell ISE

1. Open **PowerShell ISE as Administrator**.
2. Open the script:

```powershell
C:\Pshell\ShowDatabases.ps1
```

3. Comment out the old line (add `#` at the start), then add:

```powershell
# Invoke-Sqlcmd -Query "SELECT name FROM sys.databases" -ServerInstance "localhost"

Invoke-Sqlcmd -Query "SELECT name FROM sysjobs" -ServerInstance "localhost" -Database msdb | Tee-Object -FilePath C:\Pshell\Jobs.csv
Invoke-Sqlcmd -Query "SELECT name FROM sys.server_principals" -ServerInstance "localhost" | Tee-Object -FilePath C:\Pshell\Logins.csv
Invoke-Sqlcmd -Query "SELECT name FROM sys.database_principals" -ServerInstance "localhost" -Database msdb | Tee-Object -FilePath C:\Pshell\MsdbUsers.csv
```

4. Press **F5** to run the script.

---

## ✅ Result

You will now see:
- A list of jobs from `msdb` on the screen and saved in `Jobs.csv`
- A list of logins from the server saved in `Logins.csv`
- A list of users in the `msdb` database saved in `MsdbUsers.csv`

These results are also displayed in the ISE output pane.

---

## 📝 Summary

- You’ve created and run PowerShell scripts manually
- You used `Invoke-Sqlcmd` to query SQL Server
- You saved query output to CSV using `Tee-Object`
- You used PowerShell ISE to edit and test scripts interactively

