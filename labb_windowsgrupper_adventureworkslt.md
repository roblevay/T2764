# Labb: Windows-grupper, logins och användare i AdventureWorksLT

## Syfte
I den här labben ska du arbeta med Windows-grupper på servern **North** och koppla dem till SQL Server-instansen **NORTH\A** samt databasen **AdventureWorksLT**.

Du ska:

- identifiera vilka användare som ingår i respektive Windows-grupp
- skapa logins i SQL Server för grupperna
- skapa användare i databasen **AdventureWorksLT**
- lägga gruppen **DBA** i serverrollen **sysadmin**
- ge gruppen **ItSupport** behörighet på **SalesLT.Product**
- ge gruppen **Controllers** behörighet på **SalesLT.SalesOrderHeader**
- verifiera resultatet med både `EXECUTE AS LOGIN =` och `EXECUTE AS USER =`

> **Obs!** I underlaget nämns gruppen **ItControllers**, men i de bifogade kommandona finns gruppen **ItSupport**. I denna labb används därför **ItSupport**.

---

## Förkunskaper
Du bör känna till:

- skillnaden mellan **login** och **user**
- skillnaden mellan behörigheter på **servernivå** och **databasnivå**
- grundläggande `GRANT`, `CREATE LOGIN`, `CREATE USER` och `ALTER SERVER ROLE`

---

## Miljö
Följande förberedelser antas redan vara gjorda på servern **North**:

```bat
REM Restore database with orphaned user to A instance
SQLCMD /S NORTH\A /i C:\SqlLabs\T2764_LabFiles\Lab01\Restore_AW_to_A.sql

REM Delete the groups and users
NET LOCALGROUP DBA /delete
NET LOCALGROUP ItSupport /delete
NET LOCALGROUP Controllers /delete
NET USER John /delete
NET USER Frank /delete
NET USER Bill /delete
NET USER Pat /delete
NET USER Jean /delete

REM Add the groups and users
NET LOCALGROUP DBA /add
NET LOCALGROUP ItSupport /add
NET LOCALGROUP Controllers /add
NET USER John /add
NET USER Frank /add
NET USER Bill /add
NET USER Pat /add
NET USER Jean /add

NET LOCALGROUP DBA John /add
NET LOCALGROUP ItSupport Frank /add
NET LOCALGROUP ItSupport Bill /add
NET LOCALGROUP ItSupport Pat /add
NET LOCALGROUP Controllers Pat /add
NET LOCALGROUP Controllers Jean /add
```

---

## Windows-grupper och medlemmar
Baserat på underlaget finns följande grupper och medlemmar:

### Grupp: DBA
- John

### Grupp: ItSupport
- Frank
- Bill
- Pat

### Grupp: Controllers
- Pat
- Jean

> Notera att **Pat** är medlem i både **ItSupport** och **Controllers**.

---

## Uppgift
Skapa en lösning i SQL Server som uppfyller följande krav:

1. Skapa Windows-logins för grupperna:
   - `NORTH\DBA`
   - `NORTH\ItSupport`
   - `NORTH\Controllers`
2. Lägg `NORTH\DBA` i den fasta serverrollen `sysadmin`.
3. I databasen `AdventureWorksLT` ska du skapa användare för grupperna.
4. Ge gruppen `NORTH\ItSupport` rättigheter på tabellen `SalesLT.Product`.
5. Ge gruppen `NORTH\Controllers` rättigheter på tabellen `SalesLT.SalesOrderHeader`.
6. Verifiera att rättigheterna fungerar genom att testa både:
   - `EXECUTE AS LOGIN = 'NORTH\...'
   - `EXECUTE AS USER = '...'

---

## Rekommenderad arbetsgång

### Del 1: Kontrollera utgångsläget
Kontrollera först om logins redan finns:

```sql
SELECT name, type_desc
FROM sys.server_principals
WHERE name IN ('NORTH\DBA', 'NORTH\ItSupport', 'NORTH\Controllers');
```

Kontrollera sedan om användare redan finns i databasen:

```sql
USE AdventureWorksLT;
GO

SELECT name, type_desc
FROM sys.database_principals
WHERE name IN ('NORTH\DBA', 'NORTH\ItSupport', 'NORTH\Controllers');
```

---

### Del 2: Skapa logins och serverrollsmedlemskap
Skapa logins för de tre Windows-grupperna och lägg gruppen **DBA** i `sysadmin`.

> Tips: använd modern syntax med `ALTER SERVER ROLE`.

---

### Del 3: Skapa användare i databasen
I databasen `AdventureWorksLT` ska du skapa användare för grupperna utifrån respektive login.

---

### Del 4: Tilldela objektbehörigheter
Tilldela lämpliga rättigheter till grupperna:

- `NORTH\ItSupport` på `SalesLT.Product`
- `NORTH\Controllers` på `SalesLT.SalesOrderHeader`

Fundera på vilken rättighetsnivå som är rimlig för respektive grupp. I denna labb räcker det att ge **SELECT** om inget annat anges.

---

## Verifiering med EXECUTE AS LOGIN
Nu ska du verifiera resultatet genom att impersonera respektive Windows-login.

### Test 1: DBA
Eftersom gruppen `NORTH\DBA` ska vara `sysadmin` bör den kunna läsa från båda tabellerna.

Exempel:

```sql
EXECUTE AS LOGIN = 'NORTH\DBA';
SELECT TOP (5) * FROM AdventureWorksLT.SalesLT.Product;
SELECT TOP (5) * FROM AdventureWorksLT.SalesLT.SalesOrderHeader;
REVERT;
```

### Test 2: ItSupport
Den här gruppen ska ha behörighet på `SalesLT.Product`.

Testa:

- att läsa från `SalesLT.Product` och få **success**
- att läsa från `SalesLT.SalesOrderHeader` och förvänta dig **permission denied**

Exempel:

```sql
EXECUTE AS LOGIN = 'NORTH\ItSupport';
SELECT TOP (5) * FROM AdventureWorksLT.SalesLT.Product;
SELECT TOP (5) * FROM AdventureWorksLT.SalesLT.SalesOrderHeader;
REVERT;
```

### Test 3: Controllers
Den här gruppen ska ha behörighet på `SalesLT.SalesOrderHeader`.

Testa:

- att läsa från `SalesLT.SalesOrderHeader` och få **success**
- att läsa från `SalesLT.Product` och förvänta dig **permission denied**

Exempel:

```sql
EXECUTE AS LOGIN = 'NORTH\Controllers';
SELECT TOP (5) * FROM AdventureWorksLT.SalesLT.SalesOrderHeader;
SELECT TOP (5) * FROM AdventureWorksLT.SalesLT.Product;
REVERT;
```

---

## Verifiering med EXECUTE AS USER
Testa nu motsvarande sak på databasanvändarnivå.

> Här använder du databasens användarnamn, alltså samma namn som användarna skapades med i `AdventureWorksLT`.

### Test 4: ItSupport som user

```sql
USE AdventureWorksLT;
GO

EXECUTE AS USER = 'NORTH\ItSupport';
SELECT TOP (5) * FROM SalesLT.Product;
SELECT TOP (5) * FROM SalesLT.SalesOrderHeader;
REVERT;
```

### Test 5: Controllers som user

```sql
USE AdventureWorksLT;
GO

EXECUTE AS USER = 'NORTH\Controllers';
SELECT TOP (5) * FROM SalesLT.SalesOrderHeader;
SELECT TOP (5) * FROM SalesLT.Product;
REVERT;
```

### Test 6: DBA som user

```sql
USE AdventureWorksLT;
GO

EXECUTE AS USER = 'NORTH\DBA';
SELECT TOP (5) * FROM SalesLT.Product;
SELECT TOP (5) * FROM SalesLT.SalesOrderHeader;
REVERT;
```

> Fundera på varför `EXECUTE AS LOGIN` och `EXECUTE AS USER` inte alltid är exakt samma sak. Vilken säkerhetsnivå byter du identitet på i respektive fall?

---

## Kontrollfrågor
Besvara följande frågor efter genomförd labb:

1. Vad är skillnaden mellan en **login** och en **user**?
2. Varför räcker det inte att skapa en login om gruppen också ska få åtkomst till en databas?
3. Vad innebär det att gruppen **DBA** läggs i `sysadmin`?
4. Varför lyckas `NORTH\ItSupport` med `SELECT` mot `SalesLT.Product` men inte mot `SalesLT.SalesOrderHeader`?
5. Varför kan samma person få behörigheter från flera grupper?
6. Vilken praktisk skillnad märker du mellan `EXECUTE AS LOGIN` och `EXECUTE AS USER`?

---

## Extra uppgift
Pat är medlem i både `NORTH\ItSupport` och `NORTH\Controllers`.

Undersök vad detta betyder i praktiken:

- Vilka rättigheter får Pat totalt?
- Hur kan du verifiera detta?
- Kan Pat läsa från båda tabellerna om du testar med Pats eget Windows-konto?

---

## Avslutning
När du är klar bör följande gälla:

- `NORTH\DBA` är login och medlem i `sysadmin`
- `NORTH\DBA`, `NORTH\ItSupport` och `NORTH\Controllers` finns som users i `AdventureWorksLT`
- `NORTH\ItSupport` kan läsa `SalesLT.Product`
- `NORTH\Controllers` kan läsa `SalesLT.SalesOrderHeader`
- lösningen är verifierad med både `EXECUTE AS LOGIN` och `EXECUTE AS USER`

