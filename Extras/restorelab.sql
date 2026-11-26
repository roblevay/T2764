--1. Skapa en databas som heter tidsdb
--2. I denna databas, skapa en tabell som heter
--veckodagar 
--CREATE TABLE veckodagar (namn VARCHAR(50))
--3. Backup av databasen
--4. Lägg till en dag
--INSERT INTO veckodagar VALUES ('Måndag')
--5. Backup av logggen
--6. Lägg till en dag
--INSERT INTO veckodagar VALUES ('Tisdag')
--7 Backup av loggen
--8. Töm tabellen
--9. Återställ databasen och första loggen
--SELECT * FROM veckodagar ska ge resultat Måndag



--Lösningsförslag

CREATE DATABASE Tidsdb

USE tidsdb
CREATE TABLE veckodagar (namn VARCHAR(50))

USE master

BACKUP DATABASE tidsdb TO DISK='c:\backup\tidsdb.bak' WITH INIT

INSERT INTO tidsdb..veckodagar VALUES ('Måndag')

BACKUP LOG tidsdb TO DISK='c:\backup\tidsdb.bak' WITH NOINIT

INSERT INTO tidsdb..veckodagar VALUES ('Tisdag')

BACKUP LOG tidsdb TO DISK='c:\backup\tidsdb.bak' WITH NOINIT

TRUNCATE TABLE tidsdb..veckodagar

RESTORE HEADERONLY FROM DISK='c:\backup\tidsdb.bak'

USE [master]
RESTORE DATABASE [Tidsdb] FROM  DISK = N'c:\backup\tidsdb.bak' 
WITH  FILE = 1,  NORECOVERY,REPLACE

RESTORE LOG [Tidsdb] FROM  DISK = N'c:\backup\tidsdb.bak' 
WITH  FILE = 2

SELECT * FROM tidsdb..veckodagar

GO

