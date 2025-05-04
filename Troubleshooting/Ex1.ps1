# Laddar in SQL Server SMO (SQL Management Objects)
Import-Module SqlServer

# Koppla till instansen
$server = New-Object Microsoft.SqlServer.Management.Smo.Server "DESKTOP-UTG2SVO"

# Ändra till Windows Authentication only (1 = Windows Only, 2 = SQL + Windows)
$server.Settings.LoginMode = [Microsoft.SqlServer.Management.SMO.ServerLoginMode]::Integrated

# Spara ändringen
$server.Alter()

# Stoppa SQL Server-tjänsten
Stop-Service -Name 'MSSQLSERVER' -Force  # För defaultinstans
# Eller t.ex. 'MSSQL$SQL2019' för namngiven instans
