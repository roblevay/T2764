I `sqlcmd` skriver du det så här:

```cmd
sqlcmd -S localhost -Q "CREATE DATABASE TestDB123"
```

Om du vill använda Windows-autentisering är det normalt standard, men du kan vara explicit:

```cmd
sqlcmd -S localhost -E -Q "CREATE DATABASE TestDB123"
```

Om du kör mot en namngiven instans, till exempel `SQLEXPRESS`:

```cmd
sqlcmd -S localhost\SQLEXPRESS -E -Q "CREATE DATABASE TestDB123"
```

Om du vill logga in med SQL-login:

```cmd
sqlcmd -S localhost -U sa -P ditt_losenord -Q "CREATE DATABASE TestDB123"
```

Motsvarigheten till din PowerShell-rad är alltså främst:

```cmd
sqlcmd -S localhost -Q "CREATE DATABASE TestDB123"
```

`Invoke-Sqlcmd` är PowerShell-cmdlet. `sqlcmd` är kommandoradsverktyget.

