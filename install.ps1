# Battery Alert Monitor - Quick Install Script
# Run this script as Administrator to install the battery monitor

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  BATTERY ALERT MONITOR - QUICK INSTALL" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# Check admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: Administrator permissions required" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Right-click on PowerShell" -ForegroundColor White
    Write-Host "2. Select 'Run as administrator'" -ForegroundColor White
    Write-Host "3. Navigate to this folder and run again" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Get current directory
$currentDir = Get-Location
$scriptPath = Join-Path $currentDir "battery_service_clean.ps1"

# Verify main script exists
if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: battery_service_clean.ps1 not found" -ForegroundColor Red
    Write-Host "Make sure you're in the correct directory" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Installing battery monitor..." -ForegroundColor Green

# Remove any existing tasks
Write-Host "Cleaning existing tasks..." -ForegroundColor Yellow
schtasks /delete /tn "BatteryAlert" /f 2>$null
schtasks /delete /tn "BatteryAlertSimple" /f 2>$null

# Create scheduled task
$taskCommand = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`""
$createResult = schtasks /create /tn "BatteryAlert" /tr $taskCommand /sc onlogon /f

if ($LASTEXITCODE -eq 0) {
    Write-Host "Task created successfully" -ForegroundColor Green
    
    # Start the task
    Write-Host "Starting battery monitor..." -ForegroundColor Green
    schtasks /run /tn "BatteryAlert"
    
    Start-Sleep -Seconds 3
    
    Write-Host ""
    Write-Host "===============================================" -ForegroundColor Green
    Write-Host "  INSTALLATION COMPLETED!" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Battery monitor is now active and will:" -ForegroundColor White
    Write-Host "  - Start automatically when you log in" -ForegroundColor Green
    Write-Host "  - Survive suspend/hibernation" -ForegroundColor Green
    Write-Host "  - Alert you when battery reaches 80%" -ForegroundColor Green
    Write-Host "  - Run invisibly in the background" -ForegroundColor Green
    Write-Host ""
    Write-Host "Useful commands:" -ForegroundColor Yellow
    Write-Host "  Check status:  schtasks /query /tn BatteryAlert" -ForegroundColor Cyan
    Write-Host "  Configure:     .\config_battery_clean.ps1 -ShowConfig" -ForegroundColor Cyan
    Write-Host "  View logs:     Get-Content '$env:ProgramData\BatteryAlert\service.log' -Tail 10" -ForegroundColor Cyan
    Write-Host ""
    
} else {
    Write-Host "ERROR: Failed to create scheduled task" -ForegroundColor Red
    Write-Host "Result: $createResult" -ForegroundColor Red
}

Write-Host "Press Enter to continue..." -ForegroundColor Gray
Read-Host