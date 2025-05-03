
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
Install-Module -Name SqlServer -Scope CurrentUser
Invoke-Sqlcmd -Query "SELECT name FROM sys.databases" -ServerInstance "localhost" -Encrypt Optional -TrustServerCertificate
```

3. Save and close.

4. Test the script in PowerShell:

```powershell
C:\Pshell\ShowDatabases.ps1
```
You may be asked whether you trust the repository. In this case, press a to confirm.
To avoid this question permanently, type:

```powershell
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
```



---

## 🧑‍💻 Step 3 – Modify Script Using PowerShell ISE

1. Open **PowerShell ISE as Administrator**.
2. Open the script:

```powershell
C:\Pshell\ShowDatabases.ps1
```

3. Comment out the old line (add `#` at the start), then add:

```powershell
# Invoke-Sqlcmd -Query "SELECT name FROM sys.databases" -ServerInstance "localhost" -Encrypt Optional -TrustServerCertificate

Invoke-Sqlcmd -Query "SELECT name FROM sysjobs" -ServerInstance "localhost" -Database msdb -Encrypt Optional -TrustServerCertificate | Tee-Object -FilePath C:\Pshell\Jobs.csv
Invoke-Sqlcmd -Query "SELECT name FROM sys.server_principals" -ServerInstance "localhost" -Encrypt Optional -TrustServerCertificate | Tee-Object -FilePath C:\Pshell\Logins.csv
Invoke-Sqlcmd -Query "SELECT name FROM sys.database_principals" -ServerInstance "localhost" -Database msdb -Encrypt Optional -TrustServerCertificate | Tee-Object -FilePath C:\Pshell\MsdbUsers.csv

```

4. Press **F5** to run the script.

---

## 🧑‍💻 Step 4 – Install the SqlServer module

To install the SqlServer module, run this in powershell:

```powershell
Install-Module -Name SqlServer -Scope CurrentUser -Force 
```
You may get different messages, depending on what is alreadt installed. It does not matter for now.

## 🧑‍💻 Step 5 – Modify Script Using PowerShell ISE

1. Open **PowerShell ISE as Administrator**.
2. Create the script:

```powershell
C:\Pshell\ShowDatabasesNew.ps1
```

Paste this in the script:

```powershell
# Import the module
Import-Module -Name SqlServer

# Show all databases
Get-SqlDatabase -ServerInstance "localhost"

# Show all jobs
Get-SqlAgentJob -ServerInstance "localhost"

# Show all logins
Get-SqlLogin -ServerInstance "localhost"

# Show info about an instance
Get-SqlInstance -ServerInstance "localhost"

# Create a database
Invoke-Sqlcmd -ServerInstance "localhost" -Query "CREATE DATABASE TestDB"

# Delete a database
Invoke-Sqlcmd -ServerInstance "localhost" -Query "DROP DATABASE TestDB"

Backup-SqlDatabase -ServerInstance "localhost" -Database "AdventureWorks" -BackupFile "C:\SqlBackups\AdventureWorks.bak"


```




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

