# Windows Battery Monitor# Battery Alert Monitor for Windows



A simple and reliable PowerShell script to monitor your laptop battery and alert you when it reaches a specific charge level. Helps protect battery health by preventing overcharging.A Windows battery monitoring service that alerts you when your battery reaches a configurable limit. Designed to survive suspend/hibernation and run automatically at startup.



## Features## Features



- 🔋 **Battery Monitoring**: Checks battery level at regular intervals- ✅ **Survives suspend/hibernation/restart** - The main purpose of this tool

- 🔔 **Smart Alerts**: Audio beep and voice notification when battery reaches limit- ✅ **Automatic startup** - Runs when you log in to Windows

- ⚡ **Low Resource Usage**: Minimal CPU and memory footprint- ✅ **Configurable battery limit** - Default 80%, easily changeable

- 📝 **Logging**: Keeps track of battery status in log file- ✅ **Multiple alert types** - Sound beep, voice synthesis, and system notifications

- ⚙️ **Configurable**: Easy JSON configuration file- ✅ **Background operation** - Runs invisibly without interrupting your work

- 🚀 **No Dependencies**: Uses only built-in Windows PowerShell features- ✅ **Detailed logging** - Track all activity for troubleshooting

- ✅ **Easy configuration** - Simple command-line tools to customize behavior

## Installation

## Quick Start

1. **Clone or download this repository**

   ```powershell1. **Download the files** to any folder

   git clone https://github.com/arielzsilavecz/windows-battery-monitor.git2. **Run as Administrator** and execute:

   cd windows-battery-monitor   ```powershell

   ```   schtasks /create /tn "BatteryAlert" /tr "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File C:\Path\To\battery_service_clean.ps1" /sc onlogon /f

   ```

2. **Run the installer**3. **Start monitoring**:

   ```powershell   ```powershell

   .\install.ps1   schtasks /run /tn "BatteryAlert"

   ```   ```



   This will:## Files Description

   - Create the configuration directory

   - Generate a default configuration file| File | Purpose |

   - Display instructions for running the monitor|------|---------|

| `battery_service_clean.ps1` | Main service script - does the actual monitoring |

## Usage| `config_battery_clean.ps1` | Configuration tool - change settings |

| `install_battery_clean.ps1` | Service installer - advanced installation |

### Start the Monitor| `battery_simple.ps1` | Simple task manager - basic operations |

| `README_final.ps1` | System status checker |

**Option 1: Hidden mode (recommended)**

```powershell## Configuration

.\start.ps1

```Change battery limit to 85%:

```powershell

**Option 2: Manual command**.\config_battery_clean.ps1 -BatteryLimit 85

```powershell```

powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File ".\battery_monitor.ps1"

```Change check interval to 30 seconds:

```powershell

### Stop the Monitor.\config_battery_clean.ps1 -CheckInterval 30

```

```powershell

.\stop.ps1Disable voice alerts:

``````powershell

.\config_battery_clean.ps1 -DisableVoice

### View Logs```



```powershellView current configuration:

Get-Content "$env:ProgramData\BatteryAlert\service.log" -Tail 50```powershell

```.\config_battery_clean.ps1 -ShowConfig

```

## Configuration

## Management Commands

Configuration file location: `C:\ProgramData\BatteryAlert\config.json`

| Command | Purpose |

Default settings:|---------|---------|

```json| `schtasks /query /tn BatteryAlert` | Check status |

{| `schtasks /run /tn BatteryAlert` | Start manually |

  "BatteryLimit": 80,| `schtasks /end /tn BatteryAlert` | Stop monitoring |

  "CheckInterval": 60,| `schtasks /delete /tn BatteryAlert /f` | Remove completely |

  "AlertEnabled": true,

  "VoiceEnabled": true,## Logs and Troubleshooting

  "NotificationEnabled": false

}View recent activity:

``````powershell

Get-Content "$env:ProgramData\BatteryAlert\service.log" -Tail 10

### Configuration Options```



| Option | Type | Default | Description |Configuration file location:

|--------|------|---------|-------------|```

| `BatteryLimit` | Number | 80 | Battery percentage threshold for alerts (1-100) |C:\ProgramData\BatteryAlert\config.json

| `CheckInterval` | Number | 60 | Seconds between battery checks |```

| `AlertEnabled` | Boolean | true | Enable/disable all alerts |

| `VoiceEnabled` | Boolean | true | Enable/disable voice alerts |## Default Settings

| `NotificationEnabled` | Boolean | false | Enable/disable visual notifications (experimental) |

- **Battery Limit**: 80%

To change settings, edit the config file and the monitor will reload it automatically on the next check.- **Check Interval**: 60 seconds

- **Voice Alerts**: Enabled

## Auto-Start on Login- **Notifications**: Enabled

- **Cooldown**: 5 minutes between alerts

To run the monitor automatically when you log in to Windows:

## Why This Tool?

### Method 1: Task Scheduler (Recommended)

Many battery monitoring tools fail after suspend/hibernation. This tool:

1. Open Task Scheduler1. Uses Windows Scheduled Tasks (more reliable than services)

2. Create a new task with these settings:2. Registers for power management events

   - **Trigger**: At log on3. Automatically restarts if needed

   - **Action**: Start a program4. Logs all activity for debugging

   - **Program**: `powershell.exe`

   - **Arguments**: `-ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -File "C:\Path\To\battery_monitor.ps1"`## Requirements

   - **Run whether user is logged on or not**: Unchecked

   - **Hidden**: Checked- Windows 10/11

- PowerShell 5.1 or later

### Method 2: Startup Folder- Administrator rights (for installation only)



1. Press `Win + R` and type: `shell:startup`## License

2. Create a shortcut to `start.ps1` in the Startup folder

MIT License - Feel free to modify and distribute.

## Files

## Contributing

| File | Description |

|------|-------------|Issues and pull requests welcome! This tool was created to solve the specific problem of battery monitoring surviving suspend/hibernation cycles.

| `battery_monitor.ps1` | Main monitoring script |

| `install.ps1` | Installation script |---

| `start.ps1` | Start monitor in hidden mode |

| `stop.ps1` | Stop all monitor instances |**Author**: Created to solve battery monitoring after suspend/hibernation on Windows laptops.

| `README.md` | This file |

| `LICENSE` | MIT License |## Windows Battery Monitor



## How It Works### How does it work?

- Monitors battery level and alerts when the configured limit is reached (default: 80%).

1. The script checks your battery level every minute (configurable)- Shows notifications and can use voice if enabled.

2. When the battery is **charging** and reaches the configured limit (default: 80%)- Writes logs to `C:\ProgramData\BatteryAlert\service.log`.

3. It triggers an alert:

   - Audio beep### Recommended usage

   - Voice notification (if enabled)1. **Manual execution:**

4. The alert repeats every 5 minutes until you disconnect the charger   - Open PowerShell.

5. All activity is logged to `C:\ProgramData\BatteryAlert\service.log`   - Run:

     ```powershell

## Troubleshooting     cd "C:\Users\ariel\OneDrive\Documentos\windows-battery-monitor"

     powershell.exe -ExecutionPolicy Bypass -File .\battery_service_clean.ps1

### Monitor not starting     ```

- Make sure PowerShell execution policy allows scripts   - Keep the window open for continuous monitoring.

- Run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

2. **Automatic execution at login:**

### No alerts triggering   - Create a shortcut with this target:

- Check the configuration file has `AlertEnabled: true`     ```

- Verify battery is charging when it reaches the limit     powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Users\ariel\OneDrive\Documentos\windows-battery-monitor\battery_service_clean.ps1"

- Check logs for errors     ```

   - Place the shortcut in:

### Multiple instances running     `C:\Users\ariel\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`

- Run `.\stop.ps1` to stop all instances

- Check Task Scheduler for duplicate tasks### Important notes

- Check Startup folder for multiple shortcuts- Scheduled Task execution may not work in all environments due to Windows, OneDrive, or antivirus restrictions.

- The script and logs work correctly if run manually or from the Startup folder.

### Window flashing when plugging in charger- To view logs:

- This was caused by WMI event handlers in old versions  ```powershell

- Make sure you're using the latest version of `battery_monitor.ps1`  Get-Content "C:\ProgramData\BatteryAlert\service.log" -Tail 20

- Run `.\stop.ps1` and restart with `.\start.ps1`  ```



## Uninstall### Configuration

- The configuration file is located at `C:\ProgramData\BatteryAlert\config.json`.

1. Stop the monitor:- You can modify limits and options by running:

   ```powershell  ```powershell

   .\stop.ps1  .\config_battery_clean.ps1 -ShowConfig

   ```  ```



2. Remove from Task Scheduler or Startup folder (if configured)---



3. Delete configuration and logs (optional):For questions or issues, check the logs first and make sure to run the script as a normal user (not as a scheduled task).
   ```powershell
   Remove-Item "$env:ProgramData\BatteryAlert" -Recurse -Force
   ```

4. Delete the repository folder

## Why 80%?

Keeping laptop batteries between 20% and 80% charge can significantly extend their lifespan. Constantly charging to 100% can degrade lithium-ion batteries faster over time.

## License

MIT License - see [LICENSE](LICENSE) file for details

## Contributing

Contributions, issues, and feature requests are welcome!

## Author

**Ariel Zsilavecz**
- GitHub: [@arielzsilavecz](https://github.com/arielzsilavecz)

## Changelog

### v2.0.0 (2025-10-22)
- Complete rewrite for stability and simplicity
- Removed WMI event handlers that caused window flashing
- Simplified installation and usage
- Removed unnecessary dependencies
- Improved error handling and logging
- Clean, minimal codebase

### v1.0.0
- Initial release
- Basic battery monitoring
- Configurable alerts
