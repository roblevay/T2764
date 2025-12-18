import-module sqlserver
$ServerInstance = "north"
$LogPath = "C:\backup\DBCC_CHECKDB_north.log"
$PhysicalOnly = $false   # sätt $true om du vill ha PHYSICAL_ONLY

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message)
    $line = "{0}  {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    $line | Tee-Object -FilePath $LogPath -Append
}

Write-Log "Startar DBCC CHECKDB på server: $ServerInstance"

# Hämta databaser – ENKELT, RÅ TEXT
$dbList = sqlcmd `
    -S $ServerInstance `
    -E `
    -C `
    -d master `
    -h -1 `
    -W `
    -Q "SET NOCOUNT ON; SELECT name FROM sys.databases WHERE state = 0 AND name <> 'tempdb' ORDER BY name;"

if (-not $dbList) {
    Write-Log "FEL: Kunde inte hämta databaslista."
    exit 1
}

foreach ($dbName in $dbList) {
    $dbName = $dbName.Trim()
    if (-not $dbName) { continue }

    Write-Log "Kör DBCC CHECKDB på [$dbName] ..."

    $with = "WITH NO_INFOMSGS, ALL_ERRORMSGS"
    if ($PhysicalOnly) { $with += ", PHYSICAL_ONLY" }

    $cmd = "DBCC CHECKDB ([$dbName]) $with;"

    try {
        sqlcmd `
            -S $ServerInstance `
            -E `
            -C `
            -d master `
            -Q $cmd `
            -b `
            -t 0 | Out-Null

        Write-Log "OK: [$dbName]"
    }
    catch {
        Write-Log "FEL: [$dbName] - $($_.Exception.Message)"
    }
}

Write-Log "Klart."
