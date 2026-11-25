`OPENQUERY` är en funktion i **Microsoft SQL Server** som gör det möjligt att köra SQL-frågor direkt mot en annan databas eller server via en *Linked Server*.

Det är särskilt användbart när du vill hämta stora datamängder från en annan SQL Server, Oracle, PostgreSQL eller annan datakälla.

Den stora fördelen är att **SQL-frågan körs på den externa servern i stället för att SQL Server först hämtar hem alla data och bearbetar dem lokalt.**

## **1. Så fungerar OPENQUERY**

OPENQUERY skickar SQL-frågan till den externa servern, som returnerar resultatet.

## **2. Exempel: Hämta data från en annan SQL Server**

Anta att du har en Linked Server som heter `SQLPROD02`.

```
SELECT *
FROM OPENQUERY(SQLPROD02,
    'SELECT CustomerID, CustomerName
     FROM SalesDB.dbo.Customers
     WHERE Country = ''Sweden'''
);
```

Här händer följande:

1. Din lokala SQL Server skickar frågan till `SQLPROD02`.
2. Den externa SQL Servern filtrerar kunder med `Country = 'Sweden'`.
3. Endast resultatet skickas tillbaka.

Notera de dubbla enkla citattecknen runt `Sweden`. De krävs eftersom SQL-frågan ligger inuti en SQL-sträng.

## **3. OPENQUERY jämfört med vanlig Linked Server-fråga**

Du kan också använda en Linked Server utan `OPENQUERY`.

**Alternativ A – vanlig fyrdelad namngivning**

```
SELECT *
FROM SQLPROD02.SalesDB.dbo.Orders
WHERE OrderDate >= '2026-01-01';
```

**Alternativ B – OPENQUERY**

```
SELECT *
FROM OPENQUERY(SQLPROD02,
    'SELECT *
     FROM SalesDB.dbo.Orders
     WHERE OrderDate >= ''2026-01-01'''
);
```

Skillnaden kan bli stor när det gäller prestanda.

| Egenskap                    | Fyrdelat namn                      | OPENQUERY                         |
| --------------------------- | ---------------------------------- | --------------------------------- |
| Var frågan körs             | Lokal/distribuerad exekveringsplan | Extern server                     |
| Filtrering på extern server | Beror på optimeraren               | Explicit                          |
| JOIN med lokala tabeller    | Ja                                 | Ja, på returnerat resultat        |
| Parametrar                  | Enklare att använda                | Kräver dynamisk SQL               |
| Prestanda                   | Kan variera mycket                 | Ofta bättre vid stora datamängder |

**Viktigt:** SQL Server kan även med fyrdelade namn skicka filter och delar av frågan till den externa servern. `OPENQUERY` är därför inte automatiskt snabbare, men ger dig tydligare kontroll över vilken SQL som körs externt.

## **4. JOIN mellan lokal och extern databas**

Det här är ett vanligt användningsområde.

```
SELECT
    c.CustomerID,
    c.CustomerName,
    o.OrderID,
    o.OrderDate
FROM dbo.Customers AS c
INNER JOIN OPENQUERY(SQLPROD02,
    'SELECT CustomerID, OrderID, OrderDate
     FROM SalesDB.dbo.Orders
     WHERE OrderDate >= ''2026-01-01'''
) AS o
    ON c.CustomerID = o.CustomerID;
```

Här filtrerar den externa servern orderraderna innan de skickas till den lokala servern, där JOIN-operationen genomförs.

Det kan ge en betydande prestandaförbättring om den externa tabellen är stor och filtreringen är selektiv.

## **5. OPENQUERY med parametrar**

En begränsning är att `OPENQUERY` inte kan ta emot vanliga T-SQL-variabler som argument.

Det här fungerar **inte**:

```
DECLARE @Date DATE = '2026-01-01';

SELECT *
FROM OPENQUERY(SQLPROD02,
    'SELECT * FROM SalesDB.dbo.Orders
     WHERE OrderDate >= @Date');
```

I stället behöver du bygga frågan dynamiskt.

```
DECLARE @Date DATE = '2026-01-01';
DECLARE @SQL NVARCHAR(MAX);

SET @SQL = N'
SELECT *
FROM OPENQUERY(SQLPROD02,
    ''SELECT *
      FROM SalesDB.dbo.Orders
      WHERE OrderDate >= ''''' +
      CONVERT(VARCHAR(10), @Date, 120) +
      N''''''
)';

EXEC sys.sp_executesql @SQL;
```

Var noga med att hantera citattecken och validera indata när dynamisk SQL byggs.

## **6. Kan man göra INSERT, UPDATE och DELETE?**

Ja. `OPENQUERY` kan även användas för att ändra data på en extern server, om datakällan och OLE DB-providern stöder det och rätt behörigheter finns.

Exempel:

```
UPDATE OPENQUERY(SQLPROD02,
    'SELECT Status
     FROM SalesDB.dbo.Orders
     WHERE OrderID = 1001'
)
SET Status = 'Closed';
```

Det är dock viktigt att testa detta noggrant, särskilt eftersom distribuerade transaktioner och providerbegränsningar kan påverka beteendet.

## **7. Begränsningar att känna till**

- Kräver att en Linked Server är konfigurerad.
- Frågesträngen får vara maximalt 8 KB.
- Accepterar inte variabler direkt.
- Returnerar endast den första resultatuppsättningen.
- Behörigheter och autentisering styrs av Linked Server-konfigurationen.
- Prestandan påverkas av nätverket, datakällan och dess frågeoptimerare.

## **8. När rekommenderar jag OPENQUERY?**

| Situation                                        | Rekommendation                       |
| ------------------------------------------------ | ------------------------------------ |
| Hämta miljontals rader från en annan SQL Server  | OPENQUERY med filtrering             |
| Hämta ett fåtal rader från en liten tabell       | Fyrdelat namn fungerar ofta bra      |
| Fråga mot Oracle                                 | OPENQUERY är ofta fördelaktigt       |
| Många dynamiska parametrar                       | Överväg `EXEC (...) AT LinkedServer` |
| JOIN mellan två tabeller på samma externa server | OPENQUERY så att JOIN sker externt   |
| Regelbunden synkronisering av stora datamängder  | Överväg även SSIS eller ETL          |

### **Ett extra tips: EXEC AT**

Det finns ett alternativ som ibland är mer flexibelt än `OPENQUERY`:

```
DECLARE @Date DATE = '2026-01-01';

EXEC (
    'SELECT *
     FROM SalesDB.dbo.Orders
     WHERE OrderDate >= ?',
    @Date
) AT SQLPROD02;
```

Det använder parametrar och kör kommandot direkt på den externa servern, förutsatt att RPC OUT är aktiverat och providern stöder parametrar.

**Min rekommendation:** Om du arbetar med stora databaser och Linked Servers är `OPENQUERY` ett mycket användbart verktyg för prestandaoptimering. Den största vinsten får du när du ser till att filtrering, aggregering och JOIN-operationer sker på den externa servern innan data överförs.

Vill du att jag visar ett **konkret prestandaexempel där OPENQUERY jämförs med fyrdelad namngivning**, inklusive hur man ser skillnaderna i SQL Servers execution plan?
