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
