$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$launcher = Join-Path $root "Voice assist.cmd"

if (-not (Test-Path -LiteralPath $launcher)) {
    throw "Voice assist.cmd was not found."
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -ReferencedAssemblies System.Windows.Forms -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public sealed class VoiceAssistHotkeyWindow : NativeWindow, IDisposable {
    private const int WM_HOTKEY = 0x0312;
    private const uint MOD_ALT = 0x0001;
    private const uint MOD_CONTROL = 0x0002;
    private const uint VK_D = 0x44;
    private const int HOTKEY_ID = 0x5641;
    private readonly string launcherPath;

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool RegisterHotKey(IntPtr hWnd, int id, uint fsModifiers, uint vk);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool UnregisterHotKey(IntPtr hWnd, int id);

    public VoiceAssistHotkeyWindow(string launcherPath) {
        this.launcherPath = launcherPath;
        CreateHandle(new CreateParams());
        if (!RegisterHotKey(Handle, HOTKEY_ID, MOD_CONTROL | MOD_ALT, VK_D)) {
            throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error(), "Could not register Ctrl+Alt+D.");
        }
    }

    protected override void WndProc(ref Message m) {
        if (m.Msg == WM_HOTKEY && m.WParam.ToInt32() == HOTKEY_ID) {
            Process.Start(new ProcessStartInfo {
                FileName = launcherPath,
                WorkingDirectory = System.IO.Path.GetDirectoryName(launcherPath),
                UseShellExecute = true,
                WindowStyle = ProcessWindowStyle.Hidden
            });
            return;
        }
        base.WndProc(ref m);
    }

    public void Dispose() {
        UnregisterHotKey(Handle, HOTKEY_ID);
        DestroyHandle();
    }
}
"@

$mutexName = "Global\VoiceAssistHotkey"
$createdNew = $false
$mutex = [System.Threading.Mutex]::new($true, $mutexName, [ref]$createdNew)

if (-not $createdNew) {
    return
}

$window = [VoiceAssistHotkeyWindow]::new($launcher)
try {
    [System.Windows.Forms.Application]::Run()
} finally {
    $window.Dispose()
    $mutex.ReleaseMutex()
    $mutex.Dispose()
}
