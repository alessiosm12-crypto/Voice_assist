@echo off
set "ROOT=%~dp0"
start "" /min powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%ROOT%start-voice-assist.ps1"
