# Labb: Windows-grupper, logins och användare i AdventureWorksLT

---



--I windows, skapa två grupper:

-ekonomi

-data

Lägg till Pat till gruppen ekonomi och Frank till gruppen data

1. Skapa Windows-logins för grupperna om de inte redan finns:
   - `NORTH\ekonomi`
   - `NORTH\data`
2. I databasen `AdventureWorksLT` ska du skapa användare för dessa logins.
3. Ge gruppen `NORTH\data` select-rättigheter på tabellen `SalesLT.Product`.
4. Ge gruppen `NORTH\ekonomi` select-rättigheter på tabellen `SalesLT.SalesOrderHeader`.
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
REVERT;
```

### Test  Controllers som user

```sql
USE AdventureWorksLT;
GO

EXECUTE AS USER = 'NORTH\Pat';
SELECT TOP (5) * FROM SalesLT.SalesOrderHeader;
REVERT;
```




