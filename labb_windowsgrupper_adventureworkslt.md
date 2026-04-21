# Labb: Windows-grupper, logins och användare i AdventureWorksLT




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


### Testa:


### Test 6: DBA som login

```sql

EXECUTE AS LOGIN = 'NORTH\John';
CREATE DATABASE xyz123
DROP DATABASE xyz123
REVERT;
```



---

## Verifiering med EXECUTE AS USER


> Här använder du databasens användarnamn, alltså samma namn som användarna skapades med i `AdventureWorksLT`.

### Test 4: ItSupport som user

```sql
USE AdventureWorksLT;
GO

EXECUTE AS USER = 'NORTH\Frank';
SELECT TOP (5) * FROM SalesLT.Product;
SELECT TOP (5) * FROM SalesLT.SalesOrderHeader;
REVERT;
```

### Test 5: Controllers som user

```sql
USE AdventureWorksLT;
GO

EXECUTE AS USER = 'NORTH\Pat';
SELECT TOP (5) * FROM SalesLT.SalesOrderHeader;
SELECT TOP (5) * FROM SalesLT.Product;
REVERT;
```




