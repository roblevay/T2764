
# 🧪 Exercise 1: SQL Server Agent Roles – Managing Jobs with Fixed Roles

## 🎯 Objective

Understand and test the functionality of SQL Server Agent roles:
- `SQLAgentUserRole`
- `SQLAgentReaderRole`
- `SQLAgentOperatorRole`

These roles are defined in the `msdb` database.

---

## 📁 Step 1 – Create Test Logins and Users

1. In SSMS, run:

```sql
CREATE LOGIN AgentUser WITH PASSWORD = 'P@ssword123';
CREATE LOGIN AgentReader WITH PASSWORD = 'P@ssword123';
CREATE LOGIN AgentOperator WITH PASSWORD = 'P@ssword123';

USE msdb;
CREATE USER AgentUser FOR LOGIN AgentUser;
CREATE USER AgentReader FOR LOGIN AgentReader;
CREATE USER AgentOperator FOR LOGIN AgentOperator;
```

---

## 🔐 Step 2 – Add to Roles

```sql
-- Only one role per user for clear testing
EXEC sp_addrolemember 'SQLAgentUserRole', 'AgentUser';
EXEC sp_addrolemember 'SQLAgentReaderRole', 'AgentReader';
EXEC sp_addrolemember 'SQLAgentOperatorRole', 'AgentOperator';
```

---

## 🧪 Step 3 – Create a Job as AgentUser

1. Connect to SSMS using login `AgentUser`.
2. Create a job called `TestJob_AgentUser` with one step:

```sql
PRINT 'Hello from AgentUser';
```
Verify that you can run the job.
Try to read other jobs. You should only see your own job.
---

## 👁️ Step 4 –AgentReader

### Log in as `AgentReader`:

1. Connect to SSMS using login `AgentReader`.
2. Create a job called `TestJob_AgentReader` with one step:

```sql
PRINT 'Hello from AgentReader';
```
4. Verify that you can run the job.
5. Read the job called `TestJob_AgentUser. This should work. You should see all the jobs on the server.
6. Try to start this job. This should not work

### SQLAgentReaderRole
- ✅ Can create their own jobs
- ✅ Can **view** jobs owned by others (e.g., `TestJob_AgentUser`)
- ❌ Cannot modify, enable, or disable jobs they do not own


### Log in as `AgentOperator`:

1. Connect to SSMS using login `AgentOperator`.
2. Verify that you can create, view. start and stop all jobs
3. Try to modify the job `TestJob_AgentUser`. This should not work
4. Try to delete  the job `TestJob_AgentUser`. This should not work

- ✅ Same as AgentReader
- ✅ Can also **enable/disable or start/stop jobs** owned by others
- ❌ Cannot modify or delete jobs they do not own

1. Still logged in as AgentOperator, create a job named  `Operator Master` to backup the master database

```sql
BACKUP DATABASE master TO DISK = 'master.bak'
```
2. Try to execute the job. This hould not work. Why does it not work?


### Log in as `AgentOperator`:

1. Disconnect all the agent users from ssms and verify that you are logged in as North\Student using windows authentication
2. Try to execute the job `Operator Master`. It should not work
3. in the Job Properties, change the owner to sa and try to execute the job again. Now it should work
To execute a job successfully, both the owner and the user executing the job need permissions
---

## ✅ Summary

| Role                | Can Manage Own Jobs | Can View Others' Jobs | Can Enable/Disable Others' Jobs |
|---------------------|---------------------|------------------------|----------------------------------|
| SQLAgentUserRole    | ✅                  | ❌                     | ❌                               |
| SQLAgentReaderRole  | ✅                  | ✅                     | ❌                               |
| SQLAgentOperatorRole| ✅                  | ✅                     | ✅                               |

These roles are useful for delegating job management securely in multi-user environments.




# 🧪 Exercise 2: SQL Server Security - using Credentials and proxies


## 🎯 Objective

1. Create a Windows user: `North\testuser` with password `myS3cret`.
2. Configure SQL Server Agent to run under this account.
3. Create a SQL Agent job that fails to run a CmdExec step due to insufficient privileges.
4. Create a credential using `North\Student` with `myS3cret`.
5. Create a proxy named `studproxy` based on that credential.
6. Update the job to use the proxy so it succeeds.

---

## 🛠️ Step 1 – Create a Windows User

1. Open PowerShell or Computer Management.
2. Create user: `North\testuser`  
   Password: `myS3cret`

Example (PowerShell as admin):

```powershell
net user testuser myS3cret /add /domain
```

---

## 🧰 Step 2 – Set SQL Server Agent to Run as testuser

1. Open **SQL Server Configuration Manager**.
2. Go to **SQL Server Services**.
3. Right-click **SQL Server Agent** → **Properties**.
4. On the **Log On** tab:
   - Select **This account**
   - Enter `North\testuser`
   - Password: `myS3cret`
5. Click **OK**, then restart **SQL Server Agent**.

---

## ❌ Step 3 – Create a Failing CmdExec Job Step

1. In SSMS, create a new job called `Test Cmd Job`.
2. Add a step:
   - Type: **Operating system (CmdExec)**
   - Command:

```cmd
whoami > C:\DemoDatabases\whoami.txt
```

3. Run the job. It should fail with "Access Denied" unless `testuser` is local admin.

---

Tack Robert! Här kommer din begärda omskrivning – samma sak men med **grafiska steg i SSMS**, så du slipper skriva T-SQL.

---

## 🔐 Step 4 – Create a Credential 

1. In SSMS, expand **Security** > right-click **Credentials** > **New Credential**.
2. In the dialog:
   - **Credential Name**: `Cred_Student`
   - **Identity**: `North\Student`
   - **Password**: `myS3cret`
   - Confirm the password
3. Click **OK**.

✅ You've now created a credential that can be used to run jobs under a different Windows account.

---

## 🧑‍💼 Step 5 – Create a Proxy 

1. Expand **SQL Server Agent** > **Proxies** > **Operating System (CmdExec)**.
2. Right-click **CmdExec** > **New Proxy**.
3. Fill in:
   - **Proxy name**: `studproxy`
   - **Credential name**: choose `Cred_Student` from the dropdown
   - **Description**: (optional)
4. Under **Subsystems**, check `CmdExec`.
5. Under **Principals**, click **Add** and select:
   - A SQL Agent role (e.g., `SQLAgentUserRole` in `msdb`)
   - Or individual logins/users who can use the proxy
6. Click **OK**.

✅ You’ve now created a proxy that allows safe elevation for CmdExec job steps – without giving the Agent account full admin rights.

---


## ✅ Step 6 – Update Job to Use Proxy

1. Edit the job step.
2. In the **Run as** dropdown, choose `studproxy`.
3. Save and run the job again.

It should now succeed, and the file `C:\DemoDatabases\whoami.txt` will show `North\Student`.

---

## 📝 Summary

- SQL Server Agent can run as a low-privilege account.
- Elevated operations can be performed using proxies with credentials.
- This separates job ownership from privilege escalation cleanly and securely.

