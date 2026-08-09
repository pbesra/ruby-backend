param(
    [Parameter(Mandatory = $true)]
    [string]$TargetExePath
)

$normalizedTargetExePath = [System.IO.Path]::GetFullPath($TargetExePath)

$runningApiProcesses = Get-CimInstance Win32_Process -Filter "Name = 'ruby.api.exe'" -ErrorAction SilentlyContinue

foreach ($process in $runningApiProcesses) {
    if ([string]::IsNullOrWhiteSpace($process.ExecutablePath)) {
        continue
    }

    $normalizedProcessPath = [System.IO.Path]::GetFullPath($process.ExecutablePath)
    if (-not [string]::Equals($normalizedProcessPath, $normalizedTargetExePath, [System.StringComparison]::OrdinalIgnoreCase)) {
        continue
    }

    Stop-Process -Id $process.ProcessId -Force -ErrorAction Stop
    Write-Host "Stopped ruby.api.exe process $($process.ProcessId) to release build output locks."
}