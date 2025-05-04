# SQL Server Data Transfer Exercises (English Version)

## Preparation: Create a folder called C:\Data

## Exercise 1: Export and Import Using the Data Export Wizard

1. In SQL Server Management Studio (SSMS), right-click the **AdventureWorks** database.
2. Select **Tasks > Export Data**.
3. Choose the data source as **SQL Server Native Client 11.0** and the server name **North** and the database **Adventureworks** and click **Next**
4. Set the destination to **Flat File Destination** and the file name `c:\data\persondata.txt` and click **Next**
5. Select **Write a query to specify the data transfer** and click **Next**
6. Type `SELECT BusinessEntityID, FirstName , LastName FROM Person.Person` and click **Next**
7. In the **Configure Flat File Destination** click **Preview** and then  **OK**. Click **Next**
8. In **Save and Run Package**, select  **Run immediately** and **Save SSIS Package** and **File System**. Click **Next** 
9. Save the package as `PersonExport` and the file name `c:\data\PersonExport.dtsx`
10. Click **Finish** and then **Close**
11. Check the folder **C:\Data** It should contain a package and a text file. Open the text file and verify that it is correct


---

## Exercise 2: Export with BCP and Import with BULK INSERT

1.Create a table to insert data to

```sql
CREATE TABLE Adventureworks.dbo.PersonCopy
(
BusinessEntityID    INT
,FirstName VARCHAR(50)
,LastName VARCHAR(50)
)
```

2. Use `bcp` to export a file to a table (run from Command Prompt):

```bash
bcp AdventureWorks.dbo.PersonCopy in C:\Data\Persondata.txt -c -t, -T -S localhost
```

3.Check the table contents

```sql
SELECT * FROM AdventureWorks.dbo.PersonCopy
```

4. Empty the `PersonCopy` table:

```sql
TRUNCATE TABLE PersonCopy;
```

4. Use `BULK INSERT` to load the data:

```sql
BULK INSERT PersonCopy
FROM 'C:\Path\To\PersonBcp.txt'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);
```

## Exercise 3: Use BULK INSERT to Load Data

1. Empty the `PersonCopy` table:

```sql
TRUNCATE TABLE PersonCopy;
```

2. Use `BULK INSERT` to refill it from the original flat file:

```sql
BULK INSERT PersonCopy
FROM 'C:\Path\To\PersonData.txt'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
```

---



---

## Exercise 4: Query a Flat File Using OPENQUERY

> Note: This requires setting up a linked server to `Microsoft.ACE.OLEDB.12.0` or `Microsoft.Jet.OLEDB.4.0` for text file access.

1. Create a linked server to a folder containing the text file:

```sql
EXEC sp_addlinkedserver
    @server = 'TextFileServer',
    @srvproduct = 'Jet 4.0',
    @provider = 'Microsoft.Jet.OLEDB.4.0',
    @datasrc = 'C:\Path\To',
    @provstr = 'Text;FMT=Delimited';
```

2. Query the text file as if it were a table:

```sql
SELECT *
FROM OPENQUERY(TextFileServer, 'SELECT * FROM PersonData.txt');
```

