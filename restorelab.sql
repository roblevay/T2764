--1. Skapa en databas som heter Restoredb
--2. Ta backup av databasen
--3. Skapa en tabell som heter siffror
CREATE TABLE siffror (col1 INT)
--4. Ta backup av loggen
--5. Lägg till några siffror
INSERT INTO siffror VALUES(1),(2),(3)
--6. Ta backup av loggen
--7. Töm tabellen
TRUNCATE TABLE siffror
--Återställ till den icke tömda tabellen


USE master
CREATE DATABASE restoredb

BACKUP DATABASE restoredb TO DISK='c:\backup\restoredb.bak' WITH INIT

CREATE TABLE restoredb..siffror (col1 INT)

BACKUP LOG restoredb TO DISK='c:\backup\restoredb.bak' WITH NOINIT

INSERT INTO restoredb..siffror VALUES(1),(2),(3)

BACKUP LOG restoredb TO DISK='c:\backup\restoredb.bak' WITH NOINIT

TRUNCATE TABLE restoredb.dbo.siffror

BACKUP LOG restoredb TO DISK='c:\backup\restoredb.bak' WITH NOINIT,NORECOVERY

RESTORE DATABASE restoredb FROM  DISK='c:\backup\restoredb.bak' WITH FILE=1, NORECOVERY
RESTORE LOG restoredb FROM  DISK='c:\backup\restoredb.bak' WITH FILE=2, NORECOVERY
RESTORE LOG restoredb FROM  DISK='c:\backup\restoredb.bak' WITH FILE=3, RECOVERY

SELECT * FROM restoredb..siffror
