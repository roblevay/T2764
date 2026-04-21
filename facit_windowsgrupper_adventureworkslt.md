# Facit: script för Windows-grupper i AdventureWorksLT

Det här scriptet skapar rätt lösning utifrån labben.

> **Obs!** I uppgiftsbeskrivningen nämns **ItControllers**, men i underlaget finns gruppen **ItSupport**. Scriptet nedan använder därför **NORTH\ItSupport**.

---

## Komplett script

```sql
/*
    Facit till labb:
    - Windows-grupper på servern NORTH
    - SQL Server-instans: NORTH\A
    - Databas: AdventureWorksLT
*/

/* =========================================================
   1. Skapa logins för Windows-grupperna om de inte finns
   ========================================================= */
USE master;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.server_principals
    WHERE name = 'NORTH\DBA'
)
    CREATE LOGIN [NORTH\DBA] FROM WINDOWS;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.server_principals
    WHERE name = 'NORTH\ItSupport'
)
    CREATE LOGIN [NORTH\ItSupport] FROM WINDOWS;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.server_principals
    WHERE name = 'NORTH\Controllers'
)
    CREATE LOGIN [NORTH\Controllers] FROM WINDOWS;
GO

/* =========================================================
   2. Lägg DBA i sysadmin
   ========================================================= */
IF NOT EXISTS (
    SELECT 1
    FROM sys.server_role_members rm
    JOIN sys.server_principals r
        ON rm.role_principal_id = r.principal_id
    JOIN sys.server_principals m
        ON rm.member_principal_id = m.principal_id
    WHERE r.name = 'sysadmin'
      AND m.name = 'NORTH\DBA'
)
    ALTER SERVER ROLE [sysadmin] ADD MEMBER [NORTH\DBA];
GO

/* =========================================================
   3. Skapa users i AdventureWorksLT
   ========================================================= */
USE AdventureWorksLT;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'NORTH\DBA'
)
    CREATE USER [NORTH\DBA] FOR LOGIN [NORTH\DBA];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'NORTH\ItSupport'
)
    CREATE USER [NORTH\ItSupport] FOR LOGIN [NORTH\ItSupport];
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = 'NORTH\Controllers'
)
    CREATE USER [NORTH\Controllers] FOR LOGIN [NORTH\Controllers];
GO

/* =========================================================
   4. Ge objektbehörigheter
   ========================================================= */
GRANT SELECT ON OBJECT::SalesLT.Product TO [NORTH\ItSupport];
GRANT SELECT ON OBJECT::SalesLT.SalesOrderHeader TO [NORTH\Controllers];
GO

/* =========================================================
   5. Verifiera servernivå med EXECUTE AS LOGIN
   ========================================================= */
PRINT 'Test som login: NORTH\\DBA';
EXECUTE AS LOGIN = 'NORTH\DBA';
SELECT TOP (5) * FROM AdventureWorksLT.SalesLT.Product;
SELECT TOP (5) * FROM AdventureWorksLT.SalesLT.SalesOrderHeader;
REVERT;
GO

PRINT 'Test som login: NORTH\\ItSupport';
EXECUTE AS LOGIN = 'NORTH\ItSupport';
SELECT TOP (5) * FROM AdventureWorksLT.SalesLT.Product;
BEGIN TRY
    SELECT TOP (5) * FROM AdventureWorksLT.SalesLT.SalesOrderHeader;
    PRINT N'Oväntat: ItSupport kunde läsa SalesOrderHeader';
END TRY
BEGIN CATCH
    PRINT N'Förväntat fel för ItSupport mot SalesOrderHeader:';
    PRINT ERROR_MESSAGE();
END CATCH;
REVERT;
GO

PRINT 'Test som login: NORTH\\Controllers';
EXECUTE AS LOGIN = 'NORTH\Controllers';
SELECT TOP (5) * FROM AdventureWorksLT.SalesLT.SalesOrderHeader;
BEGIN TRY
    SELECT TOP (5) * FROM AdventureWorksLT.SalesLT.Product;
    PRINT N'Oväntat: Controllers kunde läsa Product';
END TRY
BEGIN CATCH
    PRINT N'Förväntat fel för Controllers mot Product:';
    PRINT ERROR_MESSAGE();
END CATCH;
REVERT;
GO

/* =========================================================
   6. Verifiera databasnivå med EXECUTE AS USER
   ========================================================= */
USE AdventureWorksLT;
GO

PRINT 'Test som user: NORTH\\DBA';
EXECUTE AS USER = 'NORTH\DBA';
SELECT TOP (5) * FROM SalesLT.Product;
SELECT TOP (5) * FROM SalesLT.SalesOrderHeader;
REVERT;
GO

PRINT 'Test som user: NORTH\\ItSupport';
EXECUTE AS USER = 'NORTH\ItSupport';
SELECT TOP (5) * FROM SalesLT.Product;
BEGIN TRY
    SELECT TOP (5) * FROM SalesLT.SalesOrderHeader;
    PRINT N'Oväntat: ItSupport kunde läsa SalesOrderHeader';
END TRY
BEGIN CATCH
    PRINT N'Förväntat fel för ItSupport mot SalesOrderHeader:';
    PRINT ERROR_MESSAGE();
END CATCH;
REVERT;
GO

PRINT 'Test som user: NORTH\\Controllers';
EXECUTE AS USER = 'NORTH\Controllers';
SELECT TOP (5) * FROM SalesLT.SalesOrderHeader;
BEGIN TRY
    SELECT TOP (5) * FROM SalesLT.Product;
    PRINT N'Oväntat: Controllers kunde läsa Product';
END TRY
BEGIN CATCH
    PRINT N'Förväntat fel för Controllers mot Product:';
    PRINT ERROR_MESSAGE();
END CATCH;
REVERT;
GO

/* =========================================================
   7. Kontrollfrågor / verifiering av skapade principals
   ========================================================= */
USE master;
GO
SELECT name, type_desc
FROM sys.server_principals
WHERE name IN ('NORTH\DBA', 'NORTH\ItSupport', 'NORTH\Controllers');
GO

USE AdventureWorksLT;
GO
SELECT name, type_desc
FROM sys.database_principals
WHERE name IN ('NORTH\DBA', 'NORTH\ItSupport', 'NORTH\Controllers');
GO
```

---

## Förväntat resultat

Efter körning ska följande gälla:

- `NORTH\DBA` finns som login
- `NORTH\DBA` är medlem i `sysadmin`
- `NORTH\ItSupport` finns som login och user
- `NORTH\Controllers` finns som login och user
- `NORTH\ItSupport` kan läsa `SalesLT.Product`
- `NORTH\Controllers` kan läsa `SalesLT.SalesOrderHeader`
- test med `EXECUTE AS LOGIN` och `EXECUTE AS USER` visar rätt behörighetsbild

---

## Kommentar
Om du vill testa vad en enskild person får genom gruppmedlemskap, till exempel **Pat**, behöver Pats eget Windows-konto också finnas som login i SQL Server, eller så testar du via verklig inloggning med det kontot.
