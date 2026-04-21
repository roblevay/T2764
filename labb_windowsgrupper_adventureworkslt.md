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
2. I databasen `AdventureWorksLT` ska du skapa användare för grupperna.
3. Ge gruppen `NORTH\ItSupport` rättigheter på tabellen `SalesLT.Product`.
4. Ge gruppen `NORTH\Controllers` rättigheter på tabellen `SalesLT.SalesOrderHeader`.
5. Verifiera att rättigheterna fungerar genom att testa både:
   - `EXECUTE AS LOGIN = 'NORTH\...'
   - `EXECUTE AS USER = '...'

---


### Testa:



---

## Verifiering med EXECUTE AS USER


> Här använder du databasens användarnamn, alltså samma namn som användarna skapades med i `AdventureWorksLT`.

### Test  ItSupport som user

```sql
USE AdventureWorksLT;
GO

EXECUTE AS USER = 'NORTH\Frank';
SELECT TOP (5) * FROM SalesLT.Product;
SELECT TOP (5) * FROM SalesLT.SalesOrderHeader;
REVERT;
```

### Test  Controllers som user

```sql
USE AdventureWorksLT;
GO

EXECUTE AS USER = 'NORTH\Pat';
SELECT TOP (5) * FROM SalesLT.SalesOrderHeader;
SELECT TOP (5) * FROM SalesLT.Product;
REVERT;
```




