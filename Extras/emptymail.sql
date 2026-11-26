DECLARE @DeleteOlder datetime

SET @DeleteOlder = DATEADD(MONTH, 0, GETDATE())

EXECUTE msdb.dbo.sysmail_delete_mailitems_sp @sent_before = @DeleteOlder
EXECUTE msdb.dbo.sysmail_delete_log_sp @logged_before = @DeleteOlder
