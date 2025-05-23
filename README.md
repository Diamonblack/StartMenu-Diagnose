# StartMenu-Diagnose

PowerShell script for automated checking and troubleshooting of Windows Start Menu icons.

---

## Table of Contents

1. [Overview](#overview)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Usage](#usage)
5. [Interpreting Results](#interpreting-results)
6. [Troubleshooting](#troubleshooting)
7. [Contributing](#contributing)
8. [License](#license)

---

## Overview

`Diagnose-StartMenuIcons.ps1` performs the following checks:

* Status of key processes (`StartMenuExperienceHost`, `ShellExperienceHost`)
* Presence and size of the icon cache files
* Structure of Start Menu folders (User & Public)
* Relevant registry key configurations
* Registration status of the Start Menu AppX package

At the end, the script outputs a checklist (✔ = OK, ✖ = action required).

## Requirements

* Windows 10 or 11
* PowerShell 5.1 or later
* Execution Policy set to at least `RemoteSigned` (or temporarily bypassed)
* Administrator privileges

## Installation

1. Clone the repository:

   ```powershell
   git clone https://github.com/Diamonblack/StartMenu-Diagnose.git
   cd StartMenu-Diagnose
   ```
2. Set the execution policy (if not already configured):

   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
   ```

## Usage

Run the script in an elevated PowerShell session:

```powershell
.\Diagnose-StartMenuIcons.ps1
```

Alternatively, bypass the policy temporarily:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Diagnose-StartMenuIcons.ps1
```

The script prints a checklist. Note any ✖ entries and follow the steps in the [Troubleshooting](#troubleshooting) section.

## Interpreting Results

* **✔**: Component is OK
* **✖**: Issue detected — corrective action required

Examples:

* `✖ Public Start Menu folder missing` → recreate folder
* `✖ Registry DisableTileLayer present` → remove key (see below)

## Troubleshooting

1. **Restore Public Start Menu folder**

   ```powershell
   New-Item -Path "C:\Users\Public\Microsoft\Windows\Start Menu\Programs" -ItemType Directory -Force
   ```
2. **Remove blocking registry keys**

   ```powershell
   Remove-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NoStartMenuMFUprogramsList -ErrorAction SilentlyContinue
   Remove-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name DisableTileLayer         -ErrorAction SilentlyContinue
   ```
3. **Rebuild icon cache**

   ```powershell
   Stop-Process -Name explorer -Force
   Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache_*.db" -Force
   Start-Process explorer
   ```
4. **Re-register Start Menu AppX package**

   ```powershell
   Get-AppxPackage Microsoft.Windows.StartMenuExperienceHost |
     ForEach-Object { Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" }
   ```
5. **Restart your PC**

## Contributing

1. Fork the repository and create a feature branch (`feature/xyz`)
2. Commit your changes (`git commit -m "feat: ..."`)
3. Push to your fork and open a Pull Request

## License

MIT © Diamonblack
