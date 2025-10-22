# Stop Battery Monitor
# This script stops all running instances of the battery monitor

Write-Host "Stopping battery monitor..." -ForegroundColor Yellow

# Find and stop battery monitor processes
$stopped = $false
Get-WmiObject Win32_Process -Filter "Name='powershell.exe'" | ForEach-Object {
    if ($_.CommandLine -like "*battery_monitor.ps1*") {
        Stop-Process -Id $_.ProcessId -Force
        Write-Host "Stopped process: $($_.ProcessId)" -ForegroundColor Green
        $stopped = $true
    }
}

if (-not $stopped) {
    Write-Host "No running battery monitor processes found" -ForegroundColor Gray
} else {
    Write-Host "Battery monitor stopped successfully" -ForegroundColor Green
}
