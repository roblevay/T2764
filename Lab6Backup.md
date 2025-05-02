
# 🧪 SQL Server – Viewing Backup History (T-SQL and GUI)

## 🎯 Objective

Learn how to view the backup history of a database using both T-SQL and SQL Server Management Studio (SSMS) graphical interface.

---

## 🔢 Method 1 – T-SQL Query to View Backup History

Use the `msdb` database, which stores all backup and restore activity.

### Example:

```sql
USE msdb
SELECT 
    bs.backup_finish_date,
    bs.type AS backup_type,
    bs.backup_size,
    bs.compressed_backup_size,
    mf.physical_device_name
FROM msdb.dbo.backupset AS bs
JOIN msdb.dbo.backupmediafamily AS mf 
    ON bs.media_set_id = mf.media_set_id
WHERE bs.database_name = 'AdventureWorks'
ORDER BY bs.backup_finish_date DESC;
```

### Backup type legend:
- D = Full Database
- I = Differential
- L = Transaction Log

---

## 🖱️ Method 2 – View Backup History Using SSMS GUI

1. Open SQL Server Management Studio (SSMS).
2. Connect to your SQL Server instance.
3. In **Object Explorer**, expand **Databases**.
4. Right-click on the database (e.g., `AdventureWorks`).
5. Go to **Reports > Standard Reports > Backup and Restore Events**.
6. The report will show:
   - Backup date and time
   - Type of backup (Full, Diff, Log)
   - Backup size
   - Device used (e.g., file path)
   - Status of each backup
7. Right-click the report and select Export. You can export this report to Excel, Word or PDF using this method.



---

## ✅ Summary

- Use **T-SQL** for custom filtering, automation, and scripting.
- Use **SSMS GUI** for quick overview and visual display.
Both methods access the same data stored in the `msdb` system database.
