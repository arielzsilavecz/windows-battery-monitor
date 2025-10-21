# Battery Service Configuration Tool (Clean Version)
# Script to configure battery service behavior

param(
    [int]$BatteryLimit,
    [int]$CheckInterval,
    [switch]$EnableVoice,
    [switch]$DisableVoice,
    [switch]$EnableNotifications,
    [switch]$DisableNotifications,
    [switch]$ShowConfig,
    [switch]$ResetConfig
)

$configDir = "$env:ProgramData\BatteryAlert"
$configFile = "$configDir\config.json"

function Ensure-ConfigDirectory {
    if (-not (Test-Path $configDir)) {
        try {
            New-Item -ItemType Directory -Path $configDir -Force | Out-Null
            Write-Host "Configuration directory created: $configDir" -ForegroundColor Green
            return $true
        } catch {
            Write-Host "Error creating directory: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }
    return $true
}

function Get-DefaultConfig {
    return @{
        BatteryLimit = 80
        CheckInterval = 60
        AlertEnabled = $true
        VoiceEnabled = $true
        NotificationEnabled = $true
        LastModified = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        Version = "1.0"
    }
}

function Load-Config {
    try {
        if (Test-Path $configFile) {
            $configJson = Get-Content $configFile -Raw | ConvertFrom-Json
            
            # Convert to hashtable for easier manipulation
            $config = @{}
            $configJson.PSObject.Properties | ForEach-Object {
                $config[$_.Name] = $_.Value
            }
            
            return $config
        }
    } catch {
        Write-Host "Error loading configuration, using defaults" -ForegroundColor Yellow
    }
    
    return Get-DefaultConfig
}

function Save-Config {
    param($config)
    
    if (-not (Ensure-ConfigDirectory)) {
        return $false
    }
    
    try {
        $config.LastModified = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        $config | ConvertTo-Json -Depth 10 | Out-File -FilePath $configFile -Encoding UTF8 -Force
        Write-Host "Configuration saved successfully" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Error saving configuration: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Show-ConfigStatus {
    Write-Host "=== BATTERY SERVICE CONFIGURATION ===" -ForegroundColor Cyan
    
    $config = Load-Config
    
    Write-Host ""
    Write-Host "Configuration file: " -ForegroundColor White -NoNewline
    Write-Host $configFile -ForegroundColor Gray
    
    if (Test-Path $configFile) {
        Write-Host "File status: " -ForegroundColor White -NoNewline
        Write-Host "Exists" -ForegroundColor Green
    } else {
        Write-Host "File status: " -ForegroundColor White -NoNewline
        Write-Host "Not found (using defaults)" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "Current configuration:" -ForegroundColor White
    Write-Host "  Battery limit: " -ForegroundColor White -NoNewline
    Write-Host "$($config.BatteryLimit)%" -ForegroundColor $(if($config.BatteryLimit -le 100){'Green'}else{'Red'})
    
    Write-Host "  Check interval: " -ForegroundColor White -NoNewline
    Write-Host "$($config.CheckInterval) seconds" -ForegroundColor Green
    
    Write-Host "  Alerts enabled: " -ForegroundColor White -NoNewline
    Write-Host $(if($config.AlertEnabled){"Yes"}else{"No"}) -ForegroundColor $(if($config.AlertEnabled){'Green'}else{'Red'})
    
    Write-Host "  Voice synthesis: " -ForegroundColor White -NoNewline
    Write-Host $(if($config.VoiceEnabled){"Enabled"}else{"Disabled"}) -ForegroundColor $(if($config.VoiceEnabled){'Green'}else{'Yellow'})
    
    Write-Host "  Notifications: " -ForegroundColor White -NoNewline
    Write-Host $(if($config.NotificationEnabled){"Enabled"}else{"Disabled"}) -ForegroundColor $(if($config.NotificationEnabled){'Green'}else{'Yellow'})
    
    if ($config.LastModified) {
        Write-Host "  Last modified: " -ForegroundColor White -NoNewline
        Write-Host $config.LastModified -ForegroundColor Gray
    }
    
    Write-Host ""
    
    # Check if service is running
    try {
        $service = Get-Service -Name "BatteryAlertService" -ErrorAction SilentlyContinue
        if ($service) {
            Write-Host "Service status: " -ForegroundColor White -NoNewline
            Write-Host $service.Status -ForegroundColor $(if($service.Status -eq 'Running'){'Green'}else{'Yellow'})
            
            if ($service.Status -eq 'Running') {
                Write-Host ""
                Write-Host "NOTE: Service is running. Changes will be applied" -ForegroundColor Yellow
                Write-Host "      in the next check cycle." -ForegroundColor Yellow
            }
        } else {
            Write-Host "Service status: " -ForegroundColor White -NoNewline
            Write-Host "Not installed" -ForegroundColor Red
        }
    } catch {}
    
    Write-Host ""
}

function Reset-Configuration {
    Write-Host "=== RESET CONFIGURATION ===" -ForegroundColor Yellow
    
    $config = Get-DefaultConfig
    
    if (Save-Config $config) {
        Write-Host ""
        Write-Host "Configuration reset to defaults:" -ForegroundColor Green
        Write-Host "  - Battery limit: 80%" -ForegroundColor White
        Write-Host "  - Interval: 60 seconds" -ForegroundColor White
        Write-Host "  - Voice: Enabled" -ForegroundColor White
        Write-Host "  - Notifications: Enabled" -ForegroundColor White
        Write-Host "  - Alerts: Enabled" -ForegroundColor White
    }
}

# MAIN EXECUTION

$config = Load-Config
$modified = $false

# Process parameters
if ($BatteryLimit) {
    if ($BatteryLimit -gt 0 -and $BatteryLimit -le 100) {
        $config.BatteryLimit = $BatteryLimit
        $modified = $true
        Write-Host "Battery limit set to $BatteryLimit%" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Limit must be between 1 and 100" -ForegroundColor Red
        exit 1
    }
}

if ($CheckInterval) {
    if ($CheckInterval -gt 0 -and $CheckInterval -le 3600) {
        $config.CheckInterval = $CheckInterval
        $modified = $true
        Write-Host "Check interval set to $CheckInterval seconds" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Interval must be between 1 and 3600 seconds" -ForegroundColor Red
        exit 1
    }
}

if ($EnableVoice) {
    $config.VoiceEnabled = $true
    $modified = $true
    Write-Host "Voice synthesis enabled" -ForegroundColor Green
}

if ($DisableVoice) {
    $config.VoiceEnabled = $false
    $modified = $true
    Write-Host "Voice synthesis disabled" -ForegroundColor Yellow
}

if ($EnableNotifications) {
    $config.NotificationEnabled = $true
    $modified = $true
    Write-Host "Notifications enabled" -ForegroundColor Green
}

if ($DisableNotifications) {
    $config.NotificationEnabled = $false
    $modified = $true
    Write-Host "Notifications disabled" -ForegroundColor Yellow
}

# Save changes if modified
if ($modified) {
    Save-Config $config
}

# Show configuration or help
if ($ShowConfig -or $modified -or (-not $PSBoundParameters.Count)) {
    Show-ConfigStatus
}

if ($ResetConfig) {
    Reset-Configuration
}

# Show help if no parameters
if (-not $PSBoundParameters.Count) {
    Write-Host "=== BATTERY SERVICE CONFIGURATOR ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\config_battery_clean.ps1 -BatteryLimit 85        # Change battery limit" -ForegroundColor White
    Write-Host "  .\config_battery_clean.ps1 -CheckInterval 30       # Change interval (seconds)" -ForegroundColor White
    Write-Host "  .\config_battery_clean.ps1 -EnableVoice            # Enable voice synthesis" -ForegroundColor White
    Write-Host "  .\config_battery_clean.ps1 -DisableVoice           # Disable voice" -ForegroundColor White
    Write-Host "  .\config_battery_clean.ps1 -EnableNotifications    # Enable notifications" -ForegroundColor White
    Write-Host "  .\config_battery_clean.ps1 -DisableNotifications   # Disable notifications" -ForegroundColor White
    Write-Host "  .\config_battery_clean.ps1 -ShowConfig             # Show current config" -ForegroundColor White
    Write-Host "  .\config_battery_clean.ps1 -ResetConfig            # Reset to defaults" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\config_battery_clean.ps1 -BatteryLimit 85 -CheckInterval 30" -ForegroundColor Cyan
    Write-Host "  .\config_battery_clean.ps1 -DisableVoice -EnableNotifications" -ForegroundColor Cyan
}