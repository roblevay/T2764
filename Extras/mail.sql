--Läs bland mail
SELECT subject,body FROM msdb.dbo.sysmail_mailitems

--Skicka mail med tsql
EXECUTE msdb.dbo.sp_send_dbmail
    @profile_name = 'Myprofile',
    @recipients = 'yourfriend@adventure-works.com',
    @body = 'Allt funkade',
    @subject = 'Viktigt meddelande';

EXECUTE msdb.dbo.sp_send_dbmail
    @profile_name = 'Myprofile',
    @recipients = 'yourfriend@adventure-works.com',
    @query = 'SELECT TOP 3 Firstname,lastname FROM adventureworks.person.person', @subject = 'Anställda'
