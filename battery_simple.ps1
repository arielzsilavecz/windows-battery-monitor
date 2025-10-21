# Battery Alert Simple Auto-Start (Clean Version)
# Simple scheduled task solution without complex XML

param(
    [switch]$Install,
    [switch]$Uninstall,
    [switch]$Start,
    [switch]$Stop,
    [switch]$Status
)

$taskName = "BatteryAlertSimple"
$scriptPath = "C:\Users\ariel\OneDrive\Documentos\battery_service_clean.ps1"

function Test-AdminRights {
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-SimpleAutoStart {
    Write-Host "=== INSTALLING SIMPLE AUTO-START ===" -ForegroundColor Cyan
    
    if (-not (Test-AdminRights)) {
        Write-Host "ERROR: Administrator permissions required" -ForegroundColor Red
        return
    }

    # Remove existing tasks
    Write-Host "Cleaning existing tasks..." -ForegroundColor Yellow
    schtasks /delete /tn "$taskName" /f 2>$null
    schtasks /delete /tn "BatteryAlertAutoStart" /f 2>$null
    schtasks /delete /tn "BatteryAlertPermanent" /f 2>$null

    # Remove old Windows service if exists
    try {
        $service = Get-Service -Name "BatteryAlertService" -ErrorAction SilentlyContinue
        if ($service) {
            Write-Host "Removing old Windows service..." -ForegroundColor Yellow
            Stop-Service -Name "BatteryAlertService" -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            & sc.exe delete "BatteryAlertService" 2>$null
        }
    } catch {}

    Write-Host "Creating simple scheduled task..." -ForegroundColor Green
    
    # Create basic task that starts at logon
    $cmd = "schtasks /create /tn `"$taskName`" /tr `"powershell.exe -ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File \`"$scriptPath\`"`" /sc onlogon /ru `"$env:USERNAME`" /rl highest /f"
    
    Write-Host "Executing: $cmd" -ForegroundColor Gray
    $result = Invoke-Expression $cmd
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Task created successfully" -ForegroundColor Green
        
        # Configure additional settings
        Write-Host "Configuring task settings..." -ForegroundColor Green
        schtasks /change /tn "$taskName" /enable 2>$null
        
        Write-Host ""
        Write-Host "=== SIMPLE AUTO-START INSTALLED ===" -ForegroundColor Green
        Write-Host "Task Name: $taskName" -ForegroundColor White
        Write-Host "Trigger: At user logon" -ForegroundColor White
        Write-Host "Script: $scriptPath" -ForegroundColor Gray
        Write-Host ""
        Write-Host "The task will start the battery monitor when you log in" -ForegroundColor Cyan
        Write-Host ""
    } else {
        Write-Host "Error creating task: $result" -ForegroundColor Red
    }
}

function Uninstall-SimpleAutoStart {
    Write-Host "=== UNINSTALLING SIMPLE AUTO-START ===" -ForegroundColor Yellow
    
    if (-not (Test-AdminRights)) {
        Write-Host "ERROR: Administrator permissions required" -ForegroundColor Red
        return
    }

    # Stop running instances
    Stop-BatteryProcesses

    # Remove scheduled task
    $result = schtasks /delete /tn "$taskName" /f 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Auto-start removed successfully" -ForegroundColor Green
    } else {
        Write-Host "Task not found or already removed" -ForegroundColor Yellow
    }
}

function Start-SimpleAutoStart {
    Write-Host "=== STARTING BATTERY MONITOR ===" -ForegroundColor Green
    
    # Run the scheduled task
    $result = schtasks /run /tn "$taskName" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Battery monitor started successfully" -ForegroundColor Green
        Start-Sleep -Seconds 3
        Show-SimpleStatus
    } else {
        Write-Host "Error starting task. Starting manually..." -ForegroundColor Yellow
        # Start manually as fallback
        Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File `"$scriptPath`"" -WindowStyle Hidden
        Write-Host "Started manually in background" -ForegroundColor Green
        Start-Sleep -Seconds 2
        Show-SimpleStatus
    }
}

function Stop-BatteryProcesses {
    Write-Host "Stopping battery service processes..." -ForegroundColor Yellow
    
    # Stop scheduled task
    schtasks /end /tn "$taskName" 2>$null
    
    # Stop PowerShell processes running our script
    $stopped = 0
    Get-Process -Name powershell -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $cmdLine = (Get-WmiObject Win32_Process -Filter "ProcessId = $($_.Id)").CommandLine
            if ($cmdLine -like "*battery_service_clean.ps1*") {
                Write-Host "Stopping process PID $($_.Id)" -ForegroundColor Gray
                Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
                $stopped++
            }
        } catch {}
    }
    
    if ($stopped -gt 0) {
        Write-Host "Stopped $stopped battery service process(es)" -ForegroundColor Green
    } else {
        Write-Host "No battery service processes found" -ForegroundColor Gray
    }
}

function Stop-SimpleAutoStart {
    Write-Host "=== STOPPING BATTERY MONITOR ===" -ForegroundColor Yellow
    Stop-BatteryProcesses
    Show-SimpleStatus
}

function Show-SimpleStatus {
    Write-Host "=== BATTERY MONITOR STATUS ===" -ForegroundColor Cyan
    
    # Check scheduled task
    $taskExists = $false
    try {
        $taskQuery = schtasks /query /tn "$taskName" /fo csv 2>$null
        if ($LASTEXITCODE -eq 0) {
            $taskInfo = $taskQuery | ConvertFrom-Csv
            if ($taskInfo) {
                $taskExists = $true
                Write-Host "Scheduled Task: " -ForegroundColor White -NoNewline
                Write-Host "Installed" -ForegroundColor Green
                Write-Host "Task Status: " -ForegroundColor White -NoNewline
                Write-Host $taskInfo.Status -ForegroundColor $(if($taskInfo.Status -eq 'Ready'){'Green'}else{'Yellow'})
                if ($taskInfo."Last Run Time" -ne "N/A") {
                    Write-Host "Last Run: " -ForegroundColor White -NoNewline
                    Write-Host $taskInfo."Last Run Time" -ForegroundColor Gray
                }
            }
        }
    } catch {}
    
    if (-not $taskExists) {
        Write-Host "Scheduled Task: " -ForegroundColor White -NoNewline
        Write-Host "Not installed" -ForegroundColor Red
    }
    
    # Check running processes
    $runningCount = 0
    $runningProcesses = @()
    Get-Process -Name powershell -ErrorAction SilentlyContinue | ForEach-Object {
        try {
            $cmdLine = (Get-WmiObject Win32_Process -Filter "ProcessId = $($_.Id)").CommandLine
            if ($cmdLine -like "*battery_service_clean.ps1*") {
                $runningProcesses += $_
                $runningCount++
            }
        } catch {}
    }
    
    Write-Host "Running Processes: " -ForegroundColor White -NoNewline
    if ($runningCount -gt 0) {
        Write-Host "$runningCount active" -ForegroundColor Green
        $runningProcesses | ForEach-Object {
            Write-Host "  PID $($_.Id) - Started: $($_.StartTime)" -ForegroundColor Gray
        }
    } else {
        Write-Host "None" -ForegroundColor Yellow
    }
    
    # Check logs
    $logFile = "$env:ProgramData\BatteryAlert\service.log"
    if (Test-Path $logFile) {
        $lastLogEntry = Get-Content $logFile -Tail 1 -ErrorAction SilentlyContinue
        if ($lastLogEntry) {
            Write-Host "Last Activity: " -ForegroundColor White -NoNewline
            Write-Host $lastLogEntry -ForegroundColor Gray
        }
        
        Write-Host "Configuration: " -ForegroundColor White -NoNewline
        $configFile = "$env:ProgramData\BatteryAlert\config.json"
        if (Test-Path $configFile) {
            try {
                $config = Get-Content $configFile | ConvertFrom-Json
                Write-Host "Limit $($config.BatteryLimit)%, Interval $($config.CheckInterval)s" -ForegroundColor Gray
            } catch {
                Write-Host "Error reading config" -ForegroundColor Red
            }
        } else {
            Write-Host "Using defaults" -ForegroundColor Gray
        }
        
        Write-Host ""
        Write-Host "Full log: $logFile" -ForegroundColor Gray
    } else {
        Write-Host "Log: " -ForegroundColor White -NoNewline
        Write-Host "Not found" -ForegroundColor Yellow
    }
}

# MAIN EXECUTION
if ($Install) {
    Install-SimpleAutoStart
} elseif ($Uninstall) {
    Uninstall-SimpleAutoStart
} elseif ($Start) {
    Start-SimpleAutoStart
} elseif ($Stop) {
    Stop-SimpleAutoStart
} elseif ($Status) {
    Show-SimpleStatus
} else {
    Write-Host "=== BATTERY MONITOR SIMPLE AUTO-START ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Simple and reliable scheduled task solution:" -ForegroundColor White
    Write-Host "  - Starts when you log in to Windows" -ForegroundColor Green
    Write-Host "  - Survives suspend/hibernation" -ForegroundColor Green
    Write-Host "  - No complex XML configurations" -ForegroundColor Green
    Write-Host "  - Easy to manage" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\battery_simple.ps1 -Install   # Install auto-start" -ForegroundColor White
    Write-Host "  .\battery_simple.ps1 -Start     # Start monitoring now" -ForegroundColor White
    Write-Host "  .\battery_simple.ps1 -Stop      # Stop monitoring" -ForegroundColor White
    Write-Host "  .\battery_simple.ps1 -Status    # Check status" -ForegroundColor White
    Write-Host "  .\battery_simple.ps1 -Uninstall # Remove auto-start" -ForegroundColor White
    Write-Host ""
    Write-Host "Configure with: .\config_battery_clean.ps1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "NOTE: Administrator permissions required for install/uninstall" -ForegroundColor Yellow
}