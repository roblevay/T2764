
# 🧪 SQL Server Agent Roles – Managing Jobs with Fixed Roles

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

---

## 👁️ Step 4 – Test Permissions

### Log in as `AgentReader`:

- ✅ Can create their own jobs
- ✅ Can **view** jobs owned by others (e.g., `TestJob_AgentUser`)
- ❌ Cannot modify, enable, or disable jobs they do not own

### Log in as `AgentOperator`:

- ✅ Same as AgentReader
- ✅ Can also **enable/disable or start/stop jobs** owned by others

---

## ✅ Summary

| Role                | Can Manage Own Jobs | Can View Others' Jobs | Can Enable/Disable Others' Jobs |
|---------------------|---------------------|------------------------|----------------------------------|
| SQLAgentUserRole    | ✅                  | ❌                     | ❌                               |
| SQLAgentReaderRole  | ✅                  | ✅                     | ❌                               |
| SQLAgentOperatorRole| ✅                  | ✅                     | ✅                               |

These roles are useful for delegating job management securely in multi-user environments.

