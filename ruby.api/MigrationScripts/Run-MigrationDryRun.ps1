param(
    [string]$Server = 'localhost',
    [string]$User = 'postgres',
    [string]$Password = 'root',
    [string]$Database = '',
    [string]$ScriptsPath = '',
    [switch]$KeepDatabase
)

$ErrorActionPreference = 'Stop'

function Invoke-Psql {
    param(
        [string]$SqlCommand,
        [string]$TargetDatabase = 'postgres'
    )

    $arguments = @(
        '-h', $Server,
        '-U', $User,
        '-d', $TargetDatabase,
        '-v', 'ON_ERROR_STOP=1',
        '-c', $SqlCommand
    )

    & $psqlPath @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "psql failed with exit code $LASTEXITCODE while executing: $SqlCommand"
    }
}

if ([string]::IsNullOrWhiteSpace($ScriptsPath)) {
    $ScriptsPath = $PSScriptRoot
}

if ([string]::IsNullOrWhiteSpace($Database)) {
    $Database = "rubydbtest_$((Get-Date -Format 'yyyyMMddHHmmss'))"
}

$psqlPath = 'C:\Program Files\PostgreSQL\18\bin\psql.exe'
if (-not (Test-Path $psqlPath)) {
    throw "psql not found at $psqlPath"
}

$files = Get-ChildItem -Path $ScriptsPath -Filter *.sql | Sort-Object Name
if ($files.Count -eq 0) {
    throw "No SQL migration files found in $ScriptsPath"
}

$env:PGPASSWORD = $Password
$dryRunPassed = $false

try {
    Write-Host "Starting migration dry run with fresh database '$Database'..."

    Invoke-Psql "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$Database' AND pid <> pg_backend_pid();"
    Invoke-Psql "DROP DATABASE IF EXISTS $Database;"
    Invoke-Psql "CREATE DATABASE $Database;"

    foreach ($file in $files) {
        Write-Host "Running $($file.Name) against '$Database'..."
        & $psqlPath -h $Server -U $User -d $Database -v ON_ERROR_STOP=1 -f $file.FullName
        if ($LASTEXITCODE -ne 0) {
            throw "Migration script $($file.Name) failed with exit code $LASTEXITCODE"
        }
    }

    $dryRunPassed = $true
    Write-Host "Dry run completed successfully for '$Database'."
}
catch {
    Write-Error "Migration dry run failed for '$Database'. $($_.Exception.Message)"
    $dryRunPassed = $false
}
finally {
    if (-not $KeepDatabase) {
        Write-Host "Deleting dry run database '$Database'..."
        Invoke-Psql "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$Database' AND pid <> pg_backend_pid();"
        Invoke-Psql "DROP DATABASE IF EXISTS $Database;"
        Write-Host "Dry run database removed."
    }
    else {
        Write-Host "Keeping database '$Database' for inspection."
    }

    if ($dryRunPassed) {
        Write-Host "RESULT: PASS"
    }
    else {
        Write-Host "RESULT: FAIL"
    }
}
