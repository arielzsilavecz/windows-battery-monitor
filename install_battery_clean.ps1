# Battery Alert Service Installer (Clean Version)
# No special characters version

param(
    [switch]$Install,
    [switch]$Uninstall,
    [switch]$Start,
    [switch]$Stop,
    [switch]$Status
)

$serviceName = "BatteryAlertService"
$serviceDisplayName = "Battery Alert Monitor Service"
$serviceDescription = "Monitors battery level and alerts when configured limit is reached"
$scriptPath = "C:\Users\ariel\OneDrive\Documentos\battery_service_clean.ps1"
$wrapperExe = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$serviceArgs = "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File `"$scriptPath`""

function Test-AdminRights {
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-BatteryService {
    Write-Host "=== INSTALLING BATTERY SERVICE ===" -ForegroundColor Cyan
    
    if (-not (Test-AdminRights)) {
        Write-Host "ERROR: Administrator permissions required" -ForegroundColor Red
        Write-Host "Run PowerShell as Administrator and try again" -ForegroundColor Yellow
        return
    }

    # Stop and remove existing service
    try {
        $existingService = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if ($existingService) {
            Write-Host "Stopping existing service..." -ForegroundColor Yellow
            Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 3
            
            Write-Host "Removing existing service..." -ForegroundColor Yellow
            & sc.exe delete $serviceName
            Start-Sleep -Seconds 2
        }
    } catch {}

    # Verify service script exists
    if (-not (Test-Path $scriptPath)) {
        Write-Host "ERROR: Service script not found at: $scriptPath" -ForegroundColor Red
        return
    }

    # Create service using sc.exe
    Write-Host "Registering service in Windows..." -ForegroundColor Green
    
    $createCmd = "sc.exe create `"$serviceName`" binPath= `"$wrapperExe $serviceArgs`" start= auto DisplayName= `"$serviceDisplayName`""
    Write-Host "Executing: $createCmd" -ForegroundColor Gray
    
    $result = & cmd /c $createCmd 2>&1
    Write-Host $result -ForegroundColor Gray

    # Configure description
    & sc.exe description $serviceName $serviceDescription

    # Configure automatic recovery on failure
    Write-Host "Configuring automatic recovery..." -ForegroundColor Green
    & sc.exe failure $serviceName reset= 86400 actions= restart/5000/restart/10000/restart/20000

    # Configure service to start automatically
    & sc.exe config $serviceName start= auto

    Write-Host ""
    Write-Host "=== SERVICE INSTALLED SUCCESSFULLY ===" -ForegroundColor Green
    Write-Host "Name: $serviceName" -ForegroundColor White
    Write-Host "Status: Installed (stopped)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To start the service:" -ForegroundColor Cyan
    Write-Host ".\install_battery_clean.ps1 -Start" -ForegroundColor White
    Write-Host ""
    Write-Host "To check status:" -ForegroundColor Cyan
    Write-Host ".\install_battery_clean.ps1 -Status" -ForegroundColor White
}

function Uninstall-BatteryService {
    Write-Host "=== UNINSTALLING BATTERY SERVICE ===" -ForegroundColor Yellow
    
    if (-not (Test-AdminRights)) {
        Write-Host "ERROR: Administrator permissions required" -ForegroundColor Red
        return
    }

    try {
        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        if ($service) {
            Write-Host "Stopping service..." -ForegroundColor Yellow
            Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 3
            
            Write-Host "Removing service..." -ForegroundColor Yellow
            & sc.exe delete $serviceName
            
            Write-Host "Service uninstalled successfully" -ForegroundColor Green
        } else {
            Write-Host "Service is not installed" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error uninstalling service: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Start-BatteryService {
    Write-Host "=== STARTING BATTERY SERVICE ===" -ForegroundColor Green
    
    try {
        $service = Get-Service -Name $serviceName -ErrorAction Stop
        Start-Service -Name $serviceName
        Write-Host "Service started successfully" -ForegroundColor Green
        Show-ServiceStatus
    } catch {
        Write-Host "Error starting service: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Is the service installed? Use -Install to install first" -ForegroundColor Yellow
    }
}

function Stop-BatteryService {
    Write-Host "=== STOPPING BATTERY SERVICE ===" -ForegroundColor Yellow
    
    try {
        $service = Get-Service -Name $serviceName -ErrorAction Stop
        Stop-Service -Name $serviceName -Force
        Write-Host "Service stopped successfully" -ForegroundColor Green
        Show-ServiceStatus
    } catch {
        Write-Host "Error stopping service: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Show-ServiceStatus {
    Write-Host "=== BATTERY SERVICE STATUS ===" -ForegroundColor Cyan
    
    try {
        $service = Get-Service -Name $serviceName -ErrorAction Stop
        Write-Host "Name: $($service.Name)" -ForegroundColor White
        Write-Host "Status: $($service.Status)" -ForegroundColor $(if($service.Status -eq 'Running'){'Green'}else{'Yellow'})
        Write-Host "Start Type: " -NoNewline -ForegroundColor White
        
        $startType = (Get-WmiObject Win32_Service -Filter "Name='$serviceName'").StartMode
        Write-Host $startType -ForegroundColor $(if($startType -eq 'Auto'){'Green'}else{'Yellow'})
        
        # Show recent logs
        $logFile = "$env:ProgramData\BatteryAlert\service.log"
        if (Test-Path $logFile) {
            Write-Host ""
            Write-Host "Recent logs:" -ForegroundColor Cyan
            Get-Content $logFile -Tail 5 -ErrorAction SilentlyContinue | ForEach-Object {
                Write-Host "  $_" -ForegroundColor Gray
            }
            Write-Host ""
            Write-Host "Full log at: $logFile" -ForegroundColor Gray
        }
        
    } catch {
        Write-Host "Service is not installed" -ForegroundColor Red
        Write-Host "Use -Install to install it" -ForegroundColor Yellow
    }
}

# MAIN EXECUTION
if ($Install) {
    Install-BatteryService
} elseif ($Uninstall) {
    Uninstall-BatteryService
} elseif ($Start) {
    Start-BatteryService
} elseif ($Stop) {
    Stop-BatteryService
} elseif ($Status) {
    Show-ServiceStatus
} else {
    Write-Host "=== BATTERY SERVICE INSTALLER FOR WINDOWS ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This script installs a real Windows service that:" -ForegroundColor White
    Write-Host "  - Survives suspend/hibernation" -ForegroundColor Green
    Write-Host "  - Restarts automatically if it fails" -ForegroundColor Green  
    Write-Host "  - Runs with system privileges" -ForegroundColor Green
    Write-Host "  - Works in background always" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\install_battery_clean.ps1 -Install   # Install service" -ForegroundColor White
    Write-Host "  .\install_battery_clean.ps1 -Start     # Start service" -ForegroundColor White
    Write-Host "  .\install_battery_clean.ps1 -Stop      # Stop service" -ForegroundColor White
    Write-Host "  .\install_battery_clean.ps1 -Status    # Show status" -ForegroundColor White
    Write-Host "  .\install_battery_clean.ps1 -Uninstall # Uninstall" -ForegroundColor White
    Write-Host ""
    Write-Host "NOTE: Administrator permissions required for install/uninstall" -ForegroundColor Yellow
}