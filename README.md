# Battery Alert Monitor for Windows

A Windows battery monitoring service that alerts you when your battery reaches a configurable limit. Designed to survive suspend/hibernation and run automatically at startup.

## Features

- ✅ **Survives suspend/hibernation/restart** - The main purpose of this tool
- ✅ **Automatic startup** - Runs when you log in to Windows
- ✅ **Configurable battery limit** - Default 80%, easily changeable
- ✅ **Multiple alert types** - Sound beep, voice synthesis, and system notifications
- ✅ **Background operation** - Runs invisibly without interrupting your work
- ✅ **Detailed logging** - Track all activity for troubleshooting
- ✅ **Easy configuration** - Simple command-line tools to customize behavior

## Quick Start

1. **Download the files** to any folder
2. **Run as Administrator** and execute:
   ```powershell
   schtasks /create /tn "BatteryAlert" /tr "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File C:\Path\To\battery_service_clean.ps1" /sc onlogon /f
   ```
3. **Start monitoring**:
   ```powershell
   schtasks /run /tn "BatteryAlert"
   ```

## Files Description

| File | Purpose |
|------|---------|
| `battery_service_clean.ps1` | Main service script - does the actual monitoring |
| `config_battery_clean.ps1` | Configuration tool - change settings |
| `install_battery_clean.ps1` | Service installer - advanced installation |
| `battery_simple.ps1` | Simple task manager - basic operations |
| `README_final.ps1` | System status checker |

## Configuration

Change battery limit to 85%:
```powershell
.\config_battery_clean.ps1 -BatteryLimit 85
```

Change check interval to 30 seconds:
```powershell
.\config_battery_clean.ps1 -CheckInterval 30
```

Disable voice alerts:
```powershell
.\config_battery_clean.ps1 -DisableVoice
```

View current configuration:
```powershell
.\config_battery_clean.ps1 -ShowConfig
```

## Management Commands

| Command | Purpose |
|---------|---------|
| `schtasks /query /tn BatteryAlert` | Check status |
| `schtasks /run /tn BatteryAlert` | Start manually |
| `schtasks /end /tn BatteryAlert` | Stop monitoring |
| `schtasks /delete /tn BatteryAlert /f` | Remove completely |

## Logs and Troubleshooting

View recent activity:
```powershell
Get-Content "$env:ProgramData\BatteryAlert\service.log" -Tail 10
```

Configuration file location:
```
C:\ProgramData\BatteryAlert\config.json
```

## Default Settings

- **Battery Limit**: 80%
- **Check Interval**: 60 seconds
- **Voice Alerts**: Enabled
- **Notifications**: Enabled
- **Cooldown**: 5 minutes between alerts

## Why This Tool?

Many battery monitoring tools fail after suspend/hibernation. This tool:
1. Uses Windows Scheduled Tasks (more reliable than services)
2. Registers for power management events
3. Automatically restarts if needed
4. Logs all activity for debugging

## Requirements

- Windows 10/11
- PowerShell 5.1 or later
- Administrator rights (for installation only)

## License

MIT License - Feel free to modify and distribute.

## Contributing

Issues and pull requests welcome! This tool was created to solve the specific problem of battery monitoring surviving suspend/hibernation cycles.

---

**Author**: Created to solve battery monitoring after suspend/hibernation on Windows laptops.