
---

# Navigera i SQL Server via PowerShell

## 1. Starta PowerShell från kommandoprompt

```cmd
powershell
```

eller

```cmd
pwsh
```

---

## 2. Installera SqlServer-modulen

```powershell
Install-Module -Name SqlServer -Scope CurrentUser -Force -AllowClobber
```

---

## 3. Importera SqlServer-modulen

```powershell
Import-Module SqlServer
```

---

## 4. Kontrollera tillgängliga PowerShell-drives

```powershell
Get-PSDrive
```

---

## 5. Byt till SQL Server-providern

```powershell
cd SQLSERVER:\
```

Visa innehållet:

```powershell
dir
```

---

## 6. Navigera till SQL-instans

```powershell
cd SQL
dir
```

Välj server, till exempel:

```powershell
cd North
dir
```

Välj instans, till exempel:

```powershell
cd DEFAULT
dir
```

---

## 7. Navigera till databaser

```powershell
cd Databases
dir
```

---

## 8. Köra SQL-frågor med PowerShell

```powershell
Invoke-Sqlcmd `
  -ServerInstance "localhost" `
  -Database "master" `
  -Query "SELECT name FROM sys.databases"
```

---

## 9. Avsluta PowerShell

```powershell
exit
```


