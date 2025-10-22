# Battery Monitor - Minimal Version
# No window flashing, no events, just simple monitoring

$logFile = "$env:ProgramData\BatteryAlert\service.log"
$configFile = "$env:ProgramData\BatteryAlert\config.json"

# Create log directory
$logDir = Split-Path $logFile -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] [$Level] $Message"
    try {
        $logEntry | Out-File -FilePath $logFile -Append -Encoding UTF8 -ErrorAction SilentlyContinue
    } catch {}
}

function Get-Config {
    if (Test-Path $configFile) {
        try {
            return Get-Content $configFile | ConvertFrom-Json
        } catch {}
    }
    
    return @{
        BatteryLimit = 80
        CheckInterval = 60
        AlertEnabled = $true
        VoiceEnabled = $false
        NotificationEnabled = $true
    }
}

Write-Log "=== Battery Monitor Started ==="
Write-Log "PID: $PID"

while ($true) {
    try {
        $config = Get-Config
        $battery = Get-WmiObject -Class Win32_Battery -ErrorAction SilentlyContinue
        
        if ($battery) {
            $charge = [int]$battery.EstimatedChargeRemaining
            $status = $battery.BatteryStatus
            
            # Translate battery status
            $statusText = switch ($status) {
                1 { "Discharging" }
                2 { "Charging" }
                3 { "Fully Charged" }
                4 { "Low" }
                5 { "Critical" }
                6 { "Charging and High" }
                7 { "Charging and Low" }
                8 { "Charging and Critical" }
                9 { "Undefined" }
                10 { "Partially Charged" }
                default { "Unknown ($status)" }
            }
            
            Write-Log "Battery: $charge% ($statusText)"
            
            # Alert if battery is charging and over limit
            if ($charge -ge $config.BatteryLimit -and $status -eq 2 -and $config.AlertEnabled) {
                Write-Log "ALERT! Battery at $charge%" "ALERT"
                
                # Detect system language
                $culture = [System.Globalization.CultureInfo]::CurrentUICulture.TwoLetterISOLanguageName
                
                # Beep
                [console]::beep(1000, 1000)
                
                # Notification
                if ($config.NotificationEnabled) {
                    try {
                        Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
                        
                        # Set notification text based on language
                        $notifTitle = switch ($culture) {
                            "es" { "Alerta de Bateria" }
                            "pt" { "Alerta de Bateria" }
                            "fr" { "Alerte de Batterie" }
                            "it" { "Avviso Batteria" }
                            default { "Battery Alert" }
                        }
                        
                        $notifText = switch ($culture) {
                            "es" { "Bateria al $charge%. Desconecta el cargador para proteger la salud de la bateria." }
                            "pt" { "Bateria em $charge%. Desconecte o carregador para proteger a saude da bateria." }
                            "fr" { "Batterie a $charge%. Debranchez le chargeur pour proteger la sante de la batterie." }
                            "it" { "Batteria al $charge%. Scollega il caricatore per proteggere la salute della batteria." }
                            default { "Battery at $charge%. Disconnect charger to protect battery health." }
                        }
                        
                        $notification = New-Object System.Windows.Forms.NotifyIcon
                        $notification.Icon = [System.Drawing.SystemIcons]::Warning
                        $notification.BalloonTipTitle = $notifTitle
                        $notification.BalloonTipText = $notifText
                        $notification.Visible = $true
                        $notification.ShowBalloonTip(10000)
                        Start-Sleep -Seconds 2
                        $notification.Dispose()
                    } catch {
                        Write-Log "Notification error: $($_.Exception.Message)" "WARN"
                    }
                }
                
                # Voice alert
                if ($config.VoiceEnabled) {
                    try {
                        Add-Type -AssemblyName System.Speech -ErrorAction SilentlyContinue
                        $voice = New-Object System.Speech.Synthesis.SpeechSynthesizer
                        
                        # Detect system language and set voice message
                        $culture = [System.Globalization.CultureInfo]::CurrentUICulture.TwoLetterISOLanguageName
                        $message = switch ($culture) {
                            "es" { "Alerta de bateria. La bateria ha alcanzado el $charge por ciento. Desconecta el cargador." }
                            "pt" { "Alerta de bateria. A bateria atingiu $charge por cento. Desconecte o carregador." }
                            "fr" { "Alerte de batterie. La batterie a atteint $charge pour cent. Débranchez le chargeur." }
                            "it" { "Avviso batteria. La batteria ha raggiunto $charge per cento. Scollega il caricatore." }
                            default { "Battery alert. Battery reached $charge percent. Disconnect charger." }
                        }
                        
                        # Try to select appropriate voice for language
                        $availableVoices = $voice.GetInstalledVoices()
                        foreach ($v in $availableVoices) {
                            if ($v.VoiceInfo.Culture.TwoLetterISOLanguageName -eq $culture) {
                                $voice.SelectVoice($v.VoiceInfo.Name)
                                break
                            }
                        }
                        
                        $voice.Speak($message)
                        $voice.Dispose()
                    } catch {
                        Write-Log "Voice error: $($_.Exception.Message)" "WARN"
                    }
                }
                
                # Wait 5 minutes before next alert
                Start-Sleep -Seconds 300
            }
        }
        
        Start-Sleep -Seconds $config.CheckInterval
        
    } catch {
        Write-Log "Error: $($_.Exception.Message)" "ERROR"
        Start-Sleep -Seconds 60
    }
}
