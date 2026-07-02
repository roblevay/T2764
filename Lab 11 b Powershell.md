
# 🧪 PowerShell Exercise – Scripting SQL Server Discovery

## 🎯 Objective

Learn how to:
1. Create a folder and PowerShell scripts manually.
2. Display file system content.
3. Query SQL Server for metadata (databases, jobs, logins, users).
4. Use PowerShell ISE to edit scripts.
5. Output results to screen and to a CSV file.

---


## 📁 Step 0 – Uninstall and Install the Sqlserver module

1. Open Powershell as administrator

```powershell
Uninstall-Module -Name SqlServer -AllVersions -Force
```

If the module SqlServer is not installed, you will get an error message which is okey

and then 

```powershell
Install-Module -Name SqlServer -Scope CurrentUser -Force -AllowClobber
```

If there is a question about NuGet, type Y and press Enter



## 📁 Step 1 – Create Folder and First Script

1. Open a command prompt or PowerShell.
2. Remove the folder if it exists and create a new one for the scripts:

```powershell
$path = "C:\Pshell"

if (Test-Path -Path $path) {
    Remove-Item -Path $path -Recurse -Force
    Write-Host "Katalogen '$path' fanns redan och har tagits bort."
}

New-Item -Path $path -ItemType Directory | Out-Null
Write-Host "Katalogen '$path' har skapats på nytt."


```

3. Open Notepad to create a script clicking on the Windows button in the lower left corner and pressing Windows+R:

```powershell
notepad C:\Pshell\ShowContent.ps1
```

There may be a mesage that notepad cannot find the file. Click **Yes**

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

1. Open Notepad to create a script clicking on the Windows button in the lower left corner and pressing Windows+R:

```powershell
notepad C:\Pshell\ShowDatabases.ps1
```

THere may be a mesage that notepad cannot find the file. Click **Yes**

2. Paste this basic SQL discovery script:

```powershell
Invoke-Sqlcmd -Query "SELECT name FROM sys.databases" -ServerInstance "localhost" -TrustServerCertificate
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
2. Open the script **C:\Pshell\ShowDatabases.ps1**

3. Comment out the old line (add `#` at the start), then add:

```powershell

Invoke-Sqlcmd -Query "SELECT name FROM sysjobs" -ServerInstance "localhost" -Database msdb -TrustServerCertificate | Tee-Object -FilePath C:\Pshell\Jobs.csv
Invoke-Sqlcmd -Query "SELECT name FROM sys.server_principals" -ServerInstance "localhost" -TrustServerCertificate | Tee-Object -FilePath C:\Pshell\Logins.csv
Invoke-Sqlcmd -Query "SELECT name FROM sys.database_principals" -ServerInstance "localhost" -Database msdb -TrustServerCertificate | Tee-Object -FilePath C:\Pshell\MsdbUsers.csv


```

4. Press **F5** to run the script.

5. Check for the csv files in the folder C:\Pshell (The can be opened for example with notepad)

---

## 🧑‍💻 Step 4 – Install the SqlServer module

If the SqlServer module is not already installet, to install the SqlServer module, run this in powershell:

```powershell
Install-Module -Name SqlServer -Scope CurrentUser -Force -AllowClobber
```
You may get different messages, depending on what is already installed. It does not matter for now.

## 🧑‍💻 Step 5 – Modify Script Using PowerShell ISE

1. Open **PowerShell ISE as Administrator**.


Paste this in a new script window:

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
Invoke-Sqlcmd -ServerInstance "localhost" -Query "CREATE DATABASE TestDB123" -TrustServerCertificate

# Delete a database
Invoke-Sqlcmd -ServerInstance "localhost" -Query "DROP DATABASE TestDB123" -TrustServerCertificate

# Backup a database
Backup-SqlDatabase -ServerInstance "localhost" -Database "AdventureWorks" -BackupFile "$((New-Object Microsoft.SqlServer.Management.Smo.Server 'localhost').Settings.BackupDirectory)\AdventureWorks.bak" -TrustServerCertificate

```

Run each of the commands separately by selecting one and clicking Run Selection. Save the script file as **C:\Pshell\ShowNewDatabases.ps1

Close all windows


---

## 📝 Summary

- You’ve created and run PowerShell scripts manually
- You used `Invoke-Sqlcmd` to query SQL Server
- You saved query output to CSV using `Tee-Object`
- You used PowerShell ISE to edit and test scripts interactively
- .you have installed, imported and used the module Sqlserver

