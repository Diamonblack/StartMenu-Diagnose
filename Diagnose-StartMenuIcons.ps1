# Dateiname: Diagnose-StartMenuIcons.ps1
# Mit Administrator-Rechten ausführen

function Write-Status {
    param($Message,$OK)
    $symbol = if($OK){"✔"}else{"✖"}
    Write-Host "$symbol $Message"
}

# 1. Prüfe, ob die Prozesse laufen
function Test-Processes {
    $procs = @("StartMenuExperienceHost","ShellExperienceHost")
    foreach($p in $procs) {
        $running = Get-Process -Name $p -ErrorAction SilentlyContinue
        Write-Status "Prozess $p läuft" ($running -ne $null)
    }
}

# 2. Prüfe Icon-Cache-Datei
function Test-IconCache {
    $cache = "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache_*.db"
    $files = Get-ChildItem $cache -ErrorAction SilentlyContinue
    if(-not $files) {
        Write-Status "Icon-Cache-Dateien existieren" $false
    } else {
        foreach($f in $files) {
            Write-Status "Icon-Cache $($f.Name) Größe: $([math]::Round($f.Length/1KB)) KB" $true
        }
    }
}

# 3. Prüfe Startmenü-Ordner
function Test-StartMenuFolders {
    $paths = @(
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs",
        "$env:PUBLIC\Microsoft\Windows\Start Menu\Programs"
    )
    foreach($p in $paths) {
        $exists = Test-Path $p
        Write-Status "Ordner $p vorhanden" $exists
        if($exists) {
            $count = (Get-ChildItem $p -Recurse -File | Measure-Object).Count
            Write-Host "   → Einträge: $count"
        }
    }
}

# 4. Prüfe relevante Registry-Schlüssel
function Test-Registry {
    $keys = @{
        "DisableTileLayer" = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\DisableTileLayer"
        "NoStartMenuMFUprogramsList" = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NoStartMenuMFUprogramsList"
    }
    foreach($name in $keys.Keys) {
        $path = $keys[$name]
        $val = Get-ItemProperty -Path $path -Name "(default)" -ErrorAction SilentlyContinue
        $exists = $val -ne $null
        Write-Status "Registry $name vorhanden" $exists
        if($exists) { Write-Host "   → Wert: $($val.'(default)')" }
    }
}

# 5. Prüfe AppX-Installation (Startmenü-Komponente)
function Test-AppX {
    $pkg = Get-AppxPackage -Name "*Microsoft.Windows.StartMenuExperienceHost*" -ErrorAction SilentlyContinue
    Write-Status "StartMenuExperienceHost AppX-Paket installiert" ($pkg -ne $null)
}

# 6. Zusammenfassung
function Run-All {
    Write-Host "Starte Diagnosen für Startmenü-Symbole..."
    Test-Processes
    Test-IconCache
    Test-StartMenuFolders
    Test-Registry
    Test-AppX
    Write-Host "Fertig."
}

Run-All
