# SQL Server Authentication Troubleshooting Exercise

## Goal

To understand how login failures are handled in SQL Server, how to inspect the error log, and how to fix authentication mode issues.

---

## Step 1: Download and Run the PowerShell Script

Download and execute the PowerShell file:

```
Troubleshooting/Ex1.ps1
```

And the bat file

```
Troubleshooting/RunEx1.bat
```

This script configures the SQL Server to run in Windows Authentication mode **only**, and stops the SQL Server service.

---

## Step 2: Run SQLCMD Login Attempts

Open a **command prompt** (not PowerShell) and run the following commands:

```cmd
sqlcmd -S DESKTOP-UTG2SVO -U sa -P wrongpassword -Q "SELECT GETDATE();"
sqlcmd -S DESKTOP-UTG2SVO -U Sqltom -PmyS3cret -Q "SELECT GETDATE();"
sqlcmd -S DESKTOP-UTG2SVO -U olle -P wrongpassword -Q "SELECT GETDATE();"
```

All of them should **fail** . Why?
---





## Step 3: Start the SQL Server Service

Start the service manually or via PowerShell:

```powershell
Start-Service -Name 'MSSQLSERVER'
```

Then run the three `sqlcmd` commands again. They will still fail, but now:

* You can check the **SQL Server Error Log** for failed login messages.

---

## Step 4: Check SQL Server Log for Login Failures

In SSMS, run:

```sql
EXEC xp_readerrorlog 0, 1, N'Login failed';
```

You should see:

* Failure for `sa`: wrong password
* Failure for `Sqltom`: even though password is correct, login fails due to **login mode**
* Failure for `olle`: login does not exist

---

## Step 5: Enable Mixed Authentication Mode

In SSMS or via PowerShell:

```powershell
Import-Module SqlServer
$server = New-Object Microsoft.SqlServer.Management.Smo.Server "DESKTOP-UTG2SVO"
$server.Settings.LoginMode = [Microsoft.SqlServer.Management.SMO.ServerLoginMode]::Mixed
$server.Alter()
Stop-Service -Name 'MSSQLSERVER' -Force
Start-Service -Name 'MSSQLSERVER'
```

---

## Step 6: Run the SQLCMD Commands Again

```cmd
sqlcmd -S DESKTOP-UTG2SVO -U sa -P wrongpassword -Q "SELECT GETDATE();"     -- still fails
sqlcmd -S DESKTOP-UTG2SVO -U Sqltom -PmyS3cret -Q "SELECT GETDATE();"       -- should now succeed
sqlcmd -S DESKTOP-UTG2SVO -U olle -P wrongpassword -Q "SELECT GETDATE();"   -- still fails
```

---

## Conclusion

* `sa` fails due to **invalid password**.
* `Sqltom` now works because **Mixed Mode** is enabled.
* `olle` fails because the login does **not exist**.

You have now verified how SQL Server handles login attempts, where to check logs, and how to change the authentication mode.

