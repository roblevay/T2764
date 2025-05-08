# SQL Server Data Transfer Exercises

## Preparation: Create a folder called C:\Data

## Exercise 1: Export and Import Using the Data Export Wizard

1. In SQL Server Management Studio (SSMS), right-click the **AdventureWorks** database.
2. Select **Tasks > Export Data**.
3. Choose the data source as **Microsoft OLE DB Provider for SQL Server** and the server name **.** and the database **Adventureworks** and click **Next**
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

1. In SSMS, Create a table to insert data to

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

3. In SSMS, Check the table contents

```sql
SELECT * FROM AdventureWorks.dbo.PersonCopy
```
---



## Exercise 3: Use BULK INSERT to Load Data

1. Empty the `PersonCopy` table:

```sql
TRUNCATE TABLE AdventureWorks.dbo.PersonCopy;
```

2. Use `BULK INSERT` to refill it from the original flat file:

```sql
BULK INSERT AdventureWorks.dbo.PersonCopy
FROM 'C:\Data\PersonData.txt'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
```
3.Check the table contents

```sql
SELECT * FROM AdventureWorks.dbo.PersonCopy
```

---





## Exercise 4: Query a Flat File Using OPENQUERY

1. In SSMS, Create a new table to use (this is done to avoid problems with column types)

```sql
SELECT Businessentityid,firstname,lastname INTO Adventureworks.dbo.nyapersoner FROM Adventureworks.person.person
```

2. In a command prompt, create a text file called nyapersoner.txt to be used

 ```bash
bcp "SELECT * FROM [Adventureworks].[dbo].[nyapersoner]" queryout "c:\data\nyapersoner.txt" -c -T
```

3. In a command prompt, create a format file using bcp
   
 ```bash
bcp adventureworks.dbo.nyapersoner format nul -c -x -f "c:\data\nyapersoner.fmt" -S localhost -T
```

4. In SSMS, use OPENROWSET to read from the text file

```sql
SELECT Firstname,lastname
FROM OPENROWSET(
  BULK 'c:\data\nyapersoner.txt',
  FORMATFILE='c:\data\nyapersoner.fmt'
) AS t;
```


5. Delete the tables created
   
```sql
drop table Adventureworks.dbo.nyapersoner
drop table  Adventureworks.dbo.PersonCopy
```

