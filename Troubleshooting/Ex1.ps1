Import-Module SqlServer
$server = New-Object Microsoft.SqlServer.Management.Smo.Server "localhost"

# Ensure login 'sqltom' exists and set password
$loginName = "sqltom"
$login = $server.Logins[$loginName]

if (-not $login) {
    $login = New-Object Microsoft.SqlServer.Management.Smo.Login($server, $loginName)
    $login.LoginType = [Microsoft.SqlServer.Management.Smo.LoginType]::SqlLogin
    $login.Create("myS3cret", $false)
    $login.MustChangePassword = $false
    $login.PasswordPolicyEnforced = $false
    Write-Host "Login '$loginName' created."
}
else {
    $login.ChangePassword("myS3cret")
    Write-Host "Password for '$loginName' was updated."
}

# Switch to Windows Authentication mode
$server.Settings.LoginMode = [Microsoft.SqlServer.Management.SMO.ServerLoginMode]::Integrated
$server.Alter()

# Stop SQL Server service
Stop-Service -Name 'MSSQLSERVER' -Force

