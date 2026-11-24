CREATE DATABASE jungfru

USE Jungfru
DROP TABLE IF EXISTS skär
CREATE TABLE skär
(stora	INT
,små	INT)

--Vår uppgift är att göra följande
--1. Skapa tre användare i windows
--och lägga i gruppen windowskarusellen
--2. Se till användarna kommer åt tabellen 
--skär

--Windowsmetoden för behöriget
--1. Skapa en windows-grupp Windowskarusellen
--och lägg till användarna
--2. Skapa login för gruppen
--och användare i databasen jungfru
--3. Ge behörighet till tabellen
--till användaren North\Windowskarusellen

--Testa
EXECUTE AS USER='North\Andersson'
SELECT * FROM skär
REVERT
