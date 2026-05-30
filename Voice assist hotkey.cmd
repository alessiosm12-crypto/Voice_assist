@echo off
set "ROOT=%~dp0"
start "" /min powershell.exe -NoProfile -STA -ExecutionPolicy Bypass -WindowStyle Hidden -File "%ROOT%Voice assist hotkey.ps1"
