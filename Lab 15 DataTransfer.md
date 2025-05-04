# SQL Server Data Transfer Exercises (English Version)

## Preparation: Create a folder called C:\Data

## Exercise 1: Export and Import Using the Data Export Wizard

1. In SQL Server Management Studio (SSMS), right-click the **AdventureWorks** database.
2. Select **Tasks > Export Data**.
3. Choose the data source as **SQL Server Native Client 11.0 ** and the server name North and click **Next**
4. Set the destination to **Flat File Destination**.
5. Save the file as `c:\Data\PersonData.txt`.
6. Complete the wizard to export the data.

Now, import the data back:

1. Right-click the **AdventureWorks** database and choose **Tasks > Import Data**.
2. Set the source to the flat file `:\Data\PersonData.txt`.
3. Choose **AdventureWorks** as the destination.
4. Specify a new table name (e.g., `PersonCopy`).
5. Run the wizard to create and populate the new table.

---

## Exercise 2: Use BULK INSERT to Load Data

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

## Exercise 3: Export with BCP and Import with BULK INSERT

1. Use `bcp` to export a table to a file (run from Command Prompt):

```bash
bcp AdventureWorks.dbo.PersonCopy out C:\Path\To\PersonBcp.txt -c -t, -T -S localhost
```

2. Empty the `PersonCopy` table:

```sql
TRUNCATE TABLE PersonCopy;
```

3. Use `BULK INSERT` to load the data:

```sql
BULK INSERT PersonCopy
FROM 'C:\Path\To\PersonBcp.txt'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);
```

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

