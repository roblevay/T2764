# SQL Server Authentication Troubleshooting Exercise

## Goal

To understand how login failures are handled in SQL Server, how to inspect the error log, and how to fix authentication mode issues.

---

## Step 0

Verify that your sql server is configured with mixed authentication (Windows and SQL Server)

## Step 1: Download and Run the PowerShell Script

Download these two files from the Troubleshooting folder (https://github.com/roblevay/T2764/tree/main/Troubleshooting) on Github to the to the Dbfiles directory on your computer:

```
Troubleshooting/Ex1.ps1
RunEx1.bat
```

Right-click RunEx1.bat and select Run as Administrator. It will make some fuzz on your server...

---

## Step 2: Run SQLCMD Login Attempts

Open a **command prompt** (not PowerShell) and run the following commands:

```cmd
sqlcmd -S localhost  -Q "SELECT GETDATE();"
sqlcmd -S localhost -U Sqltom -PmyS3cret -Q "SELECT GETDATE();"
sqlcmd -S localhost -U olle -PmyS3cret -Q "SELECT GETDATE();"

```

All of them should **fail** . Why?
---





## Step 3: Start the SQL Server Service

Start the service via Sql Server Configuration Manager

Then run the three `sqlcmd` commands again. Two of them still fail, but now:

* You can check the **SQL Server Error Log** for failed login messages.

---

## Step 4: Check SQL Server Log for Login Failures

In SSMS, run:

```sql
EXEC xp_readerrorlog 0, 1, N'Login failed';
```

You should see:

* The first is successful
* Failure for `Sqltom`: even though password is correct, login fails due to **login mode**
* Failure for `olle`: even though password is correct, login fails due to **login mode**
---

## Step 5: Enable Mixed Authentication Mode

Change it to mixed authentication in SSMS (don't forget to restart the sql server service) or via this PowerShell script:

```powershell
Import-Module SqlServer
$server = New-Object Microsoft.SqlServer.Management.Smo.Server "North"
$server.Settings.LoginMode = [Microsoft.SqlServer.Management.SMO.ServerLoginMode]::Mixed
$server.Alter()
Stop-Service -Name 'MSSQLSERVER' -Force
Start-Service -Name 'MSSQLSERVER'
```

---

## Step 6: Run the SQLCMD Commands Again

```cmd
sqlcmd -S localhost  -Q "SELECT GETDATE();"   
sqlcmd -S localhost -U Sqltom -PmyS3cret -Q "SELECT GETDATE();"      
sqlcmd -S localhost -U olle -PmyS3cret -Q "SELECT GETDATE();"   

```
The two first should work but not the third. Why?

```sql
EXEC xp_readerrorlog 0, 1, N'Login failed';
```

Examine the login olle in SSMS. Notice that the account is disabled. Enable the account olle.
---

## Step 7: Run the SQLCMD Commands Again

```cmd
sqlcmd -S localhost  -Q "SELECT GETDATE();"   
sqlcmd -S localhost -U Sqltom -PmyS3cret -Q "SELECT GETDATE();"      
sqlcmd -S localhost -U olle -PmyS3cret -Q "SELECT GETDATE();"   
```

They should all work now!

## Conclusion

* sqlcmd -S localhost  -Q "SELECT GETDATE();" first fails because the sql server service is stopped
* `Sqltom` first fails because **Mixed Mode** is not enabled
* `olle` fails because the account is disabled.

You have now verified how SQL Server handles login attempts, where to check logs, and how to change the authentication mode.

