@echo off
setlocal EnableExtensions

rem ============================================================
rem  Creates a "Shutdown WSL" shortcut in the Start Menu.
rem  The shortcut runs shutdown-wsl.vbs (next to this file) with
rem  no console window. The launcher is copied to
rem  %USERPROFILE%\bin so the shortcut keeps working even if the
rem  dotfiles repo moves.
rem  Safe to run from a \\wsl.localhost share.
rem ============================================================

set "SELFFILE=%~f0"
set "VBS_SOURCE=%~dp0shutdown-wsl.vbs"

echo Installing the "Shutdown WSL" shortcut...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$c = Get-Content -LiteralPath $env:SELFFILE -Raw; $i = $c.LastIndexOf('#PSSTART#'); Invoke-Expression $c.Substring($i + 9)"
set "RC=%errorlevel%"

echo.
if "%RC%"=="0" (
    echo [OK] Shortcut created.
) else (
    echo [FAILED] See the message above.
)
echo.
pause
exit /b %RC%

#PSSTART#
$ErrorActionPreference = 'Stop'

$sourceVbs = $env:VBS_SOURCE
if (-not (Test-Path -LiteralPath $sourceVbs)) { throw "shutdown-wsl.vbs not found: $sourceVbs" }

$binDir    = Join-Path $env:USERPROFILE 'bin'
$targetVbs = Join-Path $binDir 'shutdown-wsl.vbs'
$startMenu = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs'
$lnkPath   = Join-Path $startMenu 'Shutdown WSL.lnk'

New-Item -ItemType Directory -Force -Path $binDir | Out-Null
Copy-Item -LiteralPath $sourceVbs -Destination $targetVbs -Force

$shell = New-Object -ComObject WScript.Shell
$sc = $shell.CreateShortcut($lnkPath)
$sc.TargetPath       = Join-Path $env:SystemRoot 'System32\wscript.exe'
$sc.Arguments        = '//B "' + $targetVbs + '"'
$sc.WorkingDirectory = $binDir
$sc.IconLocation     = (Join-Path $env:SystemRoot 'System32\wsl.exe') + ',0'
$sc.Description      = 'Shut down WSL (wsl --shutdown)'
$sc.Save()

Write-Host "  Launcher : $targetVbs"
Write-Host "  Shortcut : $lnkPath"
Write-Host ""
Write-Host "Next step: open Start, search for 'Shutdown WSL', right-click it"
Write-Host "and choose 'Pin to Start' (Windows 11 blocks programmatic pinning)."
