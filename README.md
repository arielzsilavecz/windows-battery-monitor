# Windows Battery Monitor

A simple PowerShell tool to alert you when your laptop battery reaches a set limit (default: 80%).

## Quick Start

1. **Download all files** to a folder (e.g. `windows-battery-monitor`).
2. **Open PowerShell as Administrator** in that folder.
3. Run:
   ```powershell
   .\install.ps1
   ```
4. To start monitoring (hidden):
   ```powershell
   .\start.ps1
   ```
5. To stop monitoring:
   ```powershell
   .\stop.ps1
   ```

## What It Does
- Monitors battery every minute (configurable)
- Alerts with sound and notification when charging and limit is reached
- Logs all activity to `C:\ProgramData\BatteryAlert\service.log`
- Survives suspend/hibernation

## Configuration
- File: `C:\ProgramData\BatteryAlert\config.json`
- Change `BatteryLimit`, `CheckInterval`, `AlertEnabled`, `VoiceEnabled`, `NotificationEnabled`
- Example:
  ```json
  {
    "BatteryLimit": 80,
    "CheckInterval": 60,
    "AlertEnabled": true,
    "VoiceEnabled": false,
    "NotificationEnabled": true
  }
  ```
- Edit and save; changes apply automatically

## Auto-Start
- Add a shortcut to `start.ps1` in your Startup folder (`shell:startup`)
- Or use Task Scheduler to run at login

## Logs
- View recent activity:
  ```powershell
  Get-Content "$env:ProgramData\BatteryAlert\service.log" -Tail 20
  ```

## Troubleshooting
- **No alerts?** Check config file and logs
- **Multiple alerts?** Only run one instance at a time
- **Window flashing?** Use the latest version (no WMI events)
- **Uninstall:**
  1. Run `.\stop.ps1`
  2. Delete from Startup/Task Scheduler
  3. Remove `C:\ProgramData\BatteryAlert`

## Files
- `battery_monitor.ps1` — Main script
- `install.ps1` — Setup/config
- `start.ps1` — Start in background
- `stop.ps1` — Stop all instances
- `README.md` — This file
- `LICENSE` — MIT License

---
Created by Ariel Zsilavecz. MIT License.
