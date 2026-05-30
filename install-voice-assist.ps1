$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$targetScript = Join-Path $root "Voice assist.cmd"
$hotkeyScript = Join-Path $root "Voice assist hotkey.cmd"
$desktop = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktop "Voice assist.lnk"
$startup = [Environment]::GetFolderPath("Startup")
$hotkeyShortcutPath = Join-Path $startup "Voice assist hotkey.lnk"

if (-not (Test-Path -LiteralPath $targetScript)) {
    throw "Voice assist.cmd was not found."
}

if (-not (Test-Path -LiteralPath $hotkeyScript)) {
    throw "Voice assist hotkey.cmd was not found."
}

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $targetScript
$shortcut.Arguments = ""
$shortcut.WorkingDirectory = $root
$shortcut.WindowStyle = 7
$shortcut.IconLocation = "$env:SystemRoot\System32\shell32.dll,220"
$shortcut.Hotkey = ""
$shortcut.Description = "Dictate Russian text and copy it to the clipboard."
$shortcut.Save()

$hotkeyShortcut = $shell.CreateShortcut($hotkeyShortcutPath)
$hotkeyShortcut.TargetPath = $hotkeyScript
$hotkeyShortcut.Arguments = ""
$hotkeyShortcut.WorkingDirectory = $root
$hotkeyShortcut.WindowStyle = 7
$hotkeyShortcut.IconLocation = "$env:SystemRoot\System32\shell32.dll,220"
$hotkeyShortcut.Description = "Voice assist Ctrl+Alt+D hotkey listener."
$hotkeyShortcut.Save()

Get-CimInstance Win32_Process -Filter "name = 'powershell.exe'" |
    Where-Object { $_.CommandLine -like "*Voice assist hotkey.ps1*" } |
    ForEach-Object {
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    }

Get-CimInstance Win32_Process -Filter "name = 'cmd.exe'" |
    Where-Object { $_.CommandLine -like "*Voice assist hotkey.cmd*" } |
    ForEach-Object {
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    }

Start-Process -WindowStyle Hidden -FilePath "$env:ComSpec" -WorkingDirectory $root -ArgumentList @(
    "/c",
    "`"$hotkeyScript`""
)

Write-Host "Installed desktop shortcut: $shortcutPath"
Write-Host "Installed startup hotkey listener: $hotkeyShortcutPath"
Write-Host "Hotkey listener started: Ctrl+Alt+D"
