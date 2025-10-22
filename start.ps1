# Start Battery Monitor in Hidden Mode
# This script starts the battery monitor without showing a window

$scriptPath = Join-Path $PSScriptRoot "battery_monitor.ps1"

if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: battery_monitor.ps1 not found!" -ForegroundColor Red
    exit 1
}

# Start hidden
Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -File `"$scriptPath`"" -WindowStyle Hidden

Write-Host "Battery monitor started in background" -ForegroundColor Green
Write-Host "Check logs at: $env:ProgramData\BatteryAlert\service.log" -ForegroundColor Gray
