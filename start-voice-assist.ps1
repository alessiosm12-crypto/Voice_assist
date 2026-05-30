$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$port = 57832
$serverScript = Join-Path $root "serve-voice-assist.ps1"
$url = "http://localhost:$port/"

if (-not (Test-Path -LiteralPath $serverScript)) {
    throw "serve-voice-assist.ps1 was not found."
}

$serverScriptPattern = [WildcardPattern]::Escape($serverScript)
Get-CimInstance Win32_Process -Filter "name = 'powershell.exe'" |
    Where-Object { $_.CommandLine -like "*-File*$serverScriptPattern*" } |
    ForEach-Object {
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
    }

Start-Process powershell -WindowStyle Hidden -ArgumentList @(
    "-NoProfile",
    "-STA",
    "-ExecutionPolicy", "Bypass",
    "-File", "`"$serverScript`"",
    "-Port", "$port"
)
Start-Sleep -Milliseconds 700

$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$edge = "$env:LOCALAPPDATA\Microsoft\WindowsApps\MicrosoftEdge.exe"

if (Test-Path -LiteralPath $chrome) {
    Start-Process $chrome -ArgumentList @(
        "--app=$url",
        "--window-size=640,420"
    )
} elseif (Test-Path -LiteralPath $edge) {
    Start-Process $edge -ArgumentList $url
} else {
    Start-Process $url
}
