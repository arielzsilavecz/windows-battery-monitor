# Battery Alert Windows Service Script
# Clean version without special characters

$serviceName = "BatteryAlertService"
$logFile = "$env:ProgramData\BatteryAlert\service.log"
$configFile = "$env:ProgramData\BatteryAlert\config.json"

# Create log directory if not exists
$logDir = Split-Path $logFile -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Write-ServiceLog {
    param([string]$Message, [string]$Level = "INFO")
    try {
        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $logEntry = "[$timestamp] [$Level] $Message"
        $logEntry | Out-File -FilePath $logFile -Append -Encoding UTF8 -ErrorAction SilentlyContinue
        
        # Keep only last 1000 logs
        $lines = Get-Content $logFile -ErrorAction SilentlyContinue
        if ($lines.Count -gt 1000) {
            $lines[-500..-1] | Out-File -FilePath $logFile -Encoding UTF8 -ErrorAction SilentlyContinue
        }
    } catch {}
}

function Load-Config {
    try {
        if (Test-Path $configFile) {
            $config = Get-Content $configFile | ConvertFrom-Json
            return $config
        }
    } catch {}
    
    # Default configuration
    return @{
        BatteryLimit = 80
        CheckInterval = 60
        AlertEnabled = $true
        VoiceEnabled = $true
        NotificationEnabled = $true
    }
}

function Check-Battery {
    param($config)
    
    try {
        $battery = Get-WmiObject -Class Win32_Battery -ErrorAction Stop
        if (-not $battery) {
            Write-ServiceLog "No battery detected in system" "WARN"
            return $false
        }

        $charge = [int]$battery.EstimatedChargeRemaining
        $powerStatus = $battery.BatteryStatus
        
        Write-ServiceLog "Battery: $charge% (Status: $powerStatus)"
        
        if ($charge -ge $config.BatteryLimit -and $config.AlertEnabled) {
            Write-ServiceLog "ALERT! Battery at $charge% - Limit: $($config.BatteryLimit)%" "ALERT"
            Show-BatteryAlert $charge $config
            return $true
        }
        
        return $false
        
    } catch {
        Write-ServiceLog "Error checking battery: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Show-BatteryAlert {
    param([int]$charge, $config)
    
    try {
        # System beep
        [console]::beep(1000, 1000)
        
        if ($config.NotificationEnabled) {
            # System notification
            Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
            $balloon = New-Object System.Windows.Forms.NotifyIcon -ErrorAction SilentlyContinue
            if ($balloon) {
                $balloon.Icon = [System.Drawing.SystemIcons]::Warning
                $balloon.BalloonTipTitle = "Battery Alert"
                $balloon.BalloonTipText = "Battery reached $charge%. Disconnect charger."
                $balloon.Visible = $true
                $balloon.ShowBalloonTip(10000)
                
                Start-Sleep -Seconds 12
                $balloon.Dispose()
            }
        }
        
        if ($config.VoiceEnabled) {
            # Voice synthesis
            Add-Type -AssemblyName System.Speech -ErrorAction SilentlyContinue
            $voice = New-Object System.Speech.Synthesis.SpeechSynthesizer -ErrorAction SilentlyContinue
            if ($voice) {
                $voice.Speak("Battery alert. Battery reached $charge percent. Disconnect charger.")
                $voice.Dispose()
            }
        }
        
        Write-ServiceLog "Battery alert shown successfully"
        
    } catch {
        Write-ServiceLog "Error showing alert: $($_.Exception.Message)" "ERROR"
    }
}

# MAIN SERVICE LOOP
Write-ServiceLog "=== Battery Service Started ==="
Write-ServiceLog "PID: $PID"
Write-ServiceLog "Log: $logFile"
Write-ServiceLog "Config: $configFile"

# Register power management event handler
try {
    Register-WmiEvent -Query "SELECT * FROM Win32_PowerManagementEvent" -Action {
        Write-ServiceLog "Power event detected - Service active after system event" "INFO"
    } -ErrorAction SilentlyContinue
} catch {}

# Main service loop
$lastAlert = Get-Date
$alertCooldown = 300  # 5 minutes between alerts

while ($true) {
    try {
        $config = Load-Config
        
        # Check battery
        $alertShown = Check-Battery $config
        
        # If alert shown, wait cooldown
        if ($alertShown) {
            $lastAlert = Get-Date
            Write-ServiceLog "Waiting cooldown of $($alertCooldown/60) minutes..."
            Start-Sleep -Seconds $alertCooldown
        } else {
            Start-Sleep -Seconds $config.CheckInterval
        }
        
    } catch {
        Write-ServiceLog "Error in main loop: $($_.Exception.Message)" "ERROR"
        Start-Sleep -Seconds 60
    }
}