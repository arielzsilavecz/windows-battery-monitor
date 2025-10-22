# Battery Monitor Installer
# Simple installation script for Windows Battery Monitor

Write-Host "======================================" -ForegroundColor Cyan
Write-Host " Battery Monitor Installation" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$scriptPath = Join-Path $PSScriptRoot "battery_monitor.ps1"

if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: battery_monitor.ps1 not found!" -ForegroundColor Red
    exit 1
}

# Create config directory
$configDir = "$env:ProgramData\BatteryAlert"
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    Write-Host "[OK] Created config directory: $configDir" -ForegroundColor Green
}

# Create default configuration
$configFile = "$configDir\config.json"
if (-not (Test-Path $configFile)) {
    $config = @{
        BatteryLimit = 80
        CheckInterval = 60
        AlertEnabled = $true
        VoiceEnabled = $false
        NotificationEnabled = $true
    }
    $config | ConvertTo-Json | Out-File -FilePath $configFile -Encoding UTF8
    Write-Host "[OK] Created default configuration" -ForegroundColor Green
} else {
    Write-Host "[OK] Configuration file already exists" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "To start the monitor:" -ForegroundColor White
Write-Host "  .\start.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "Configuration file: $configFile" -ForegroundColor Gray
Write-Host "Log file: $configDir\service.log" -ForegroundColor Gray
Write-Host ""
