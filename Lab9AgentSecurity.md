
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


