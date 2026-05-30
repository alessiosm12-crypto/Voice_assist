param(
    [int]$Port = 57832
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Windows.Forms

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$htmlPath = Join-Path $root "voice-assist.html"

if (-not (Test-Path -LiteralPath $htmlPath)) {
    throw "voice-assist.html was not found next to this script."
}

function Send-Bytes {
    param(
        $Response,
        [byte[]]$Body,
        [string]$ContentType,
        [int]$StatusCode = 200
    )

    $Response.StatusCode = $StatusCode
    $Response.ContentType = $ContentType
    $Response.ContentLength64 = $Body.Length
    $Response.Headers.Add("Cache-Control", "no-store")
    $Response.OutputStream.Write($Body, 0, $Body.Length)
    $Response.OutputStream.Close()
}

function Send-Text {
    param(
        $Response,
        [string]$Text,
        [int]$StatusCode = 200
    )

    Send-Bytes `
        -Response $Response `
        -Body ([System.Text.Encoding]::UTF8.GetBytes($Text)) `
        -ContentType "text/plain; charset=utf-8" `
        -StatusCode $StatusCode
}

function Send-Html {
    param($Response)

    Send-Bytes `
        -Response $Response `
        -Body ([System.IO.File]::ReadAllBytes($htmlPath)) `
        -ContentType "text/html; charset=utf-8"
}

function Read-RequestBody {
    param($Request)

    $reader = [System.IO.StreamReader]::new($Request.InputStream, [System.Text.Encoding]::UTF8)
    try {
        return $reader.ReadToEnd()
    } finally {
        $reader.Dispose()
    }
}

function Copy-TextToClipboard {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        throw "Nothing to copy."
    }

    $lastError = $null
    for ($attempt = 1; $attempt -le 8; $attempt += 1) {
        try {
            [System.Windows.Forms.Clipboard]::SetText($Text)
            return
        } catch {
            $lastError = $_.Exception.Message
            Start-Sleep -Milliseconds 180
        }
    }

    throw "Clipboard is busy: $lastError"
}

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
$listener.Start()

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        try {
            switch ($request.Url.AbsolutePath) {
                "/copy" {
                    Copy-TextToClipboard -Text (Read-RequestBody -Request $request)
                    Send-Text -Response $response -Text "ok"
                }
                default {
                    Send-Html -Response $response
                }
            }
        } catch {
            Send-Text -Response $response -Text $_.Exception.Message -StatusCode 500
        }
    }
} finally {
    $listener.Stop()
    $listener.Close()
}
