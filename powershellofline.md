För att installera PowerShell-modulen **SqlServer** på en dator utan internet gör man installationen i två steg: först hämtar man modulen på en dator som har internet, sedan kopierar man den till offline-datorn.

På internetdatorn öppnar du PowerShell och kör:

```powershell
New-Item -ItemType Directory -Path C:\Temp\PSModules -Force
Save-Module -Name SqlServer -Path C:\Temp\PSModules
```

Vill du använda en viss version kan du ange den, till exempel:

```powershell
Save-Module -Name SqlServer -RequiredVersion 22.4.5.1 -Path C:\Temp\PSModules
```

Detta laddar ner modulen i rätt mappstruktur, till exempel:

```text
C:\Temp\PSModules\SqlServer\22.4.5.1
```

Kopiera sedan hela mappen **SqlServer** till offline-datorn, till exempel med USB-minne eller filshare.

På offline-datorn ska mappen placeras i en katalog som PowerShell söker moduler i. Vanligast för Windows PowerShell 5.1 är:

```text
C:\Program Files\WindowsPowerShell\Modules
```

Resultatet ska alltså ungefär bli:

```text
C:\Program Files\WindowsPowerShell\Modules\SqlServer\22.4.5.1
```

För endast aktuell användare kan du i stället använda:

```text
C:\Users\<användare>\Documents\WindowsPowerShell\Modules
```

För PowerShell 7 kan rätt plats vara:

```text
C:\Program Files\PowerShell\Modules
```

Du kan kontrollera vilka sökvägar som används med:

```powershell
$env:PSModulePath -split ';'
```

När modulen är kopierad testar du på offline-datorn:

```powershell
Get-Module SqlServer -ListAvailable
Import-Module SqlServer
```

Därefter kan du kontrollera att kommandona finns:

```powershell
Get-Command -Module SqlServer
```

Och testa `Invoke-Sqlcmd`:

```powershell
Invoke-Sqlcmd -ServerInstance localhost -Query "SELECT @@VERSION"
```

Det viktiga är alltså att använda **Save-Module**, inte **Install-Module**, när du förbereder installationen för en offline-dator.

