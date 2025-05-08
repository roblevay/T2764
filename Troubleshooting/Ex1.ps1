Import-Module SqlServer
$server = New-Object Microsoft.SqlServer.Management.Smo.Server "localhost"
$server.Settings.LoginMode = [Microsoft.SqlServer.Management.SMO.ServerLoginMode]::Integrated
$server.Alter()
Stop-Service -Name 'MSSQLSERVER' -Force
