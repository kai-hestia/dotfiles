@echo off
setlocal EnableExtensions

rem ============================================================
rem  Installs dvorak.ahk (AutoHotkey v2) as an elevated scheduled
rem  task at logon.
rem  Safe to run from a \\wsl.localhost share: it stages itself
rem  in %TEMP% and elevates from there, and the logon trigger is
rem  delayed so WSL has time to start before the script is read.
rem ============================================================

rem ---- First run (not yet elevated): stage locally, then elevate ----
if not defined DVORAK_INSTALL_ELEVATED (
    copy /y "%~f0" "%TEMP%\install-dvorak-task.bat" >nul
    > "%TEMP%\run-install-dvorak.cmd" echo @echo off
    >>"%TEMP%\run-install-dvorak.cmd" echo set "DVORAK_SCRIPT=%~dp0dvorak.ahk"
    >>"%TEMP%\run-install-dvorak.cmd" echo set "DVORAK_INSTALL_ELEVATED=1"
    >>"%TEMP%\run-install-dvorak.cmd" echo call "%TEMP%\install-dvorak-task.bat"
    echo Requesting administrator rights...
    powershell -NoProfile -Command "Start-Process -FilePath '%TEMP%\run-install-dvorak.cmd' -Verb RunAs"
    exit /b
)

set "SELFFILE=%~f0"

echo Installing the Dvorak scheduled task...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$c = Get-Content -LiteralPath $env:SELFFILE -Raw; $i = $c.LastIndexOf('#PSSTART#'); Invoke-Expression $c.Substring($i + 9)"
set "RC=%errorlevel%"

echo.
if "%RC%"=="0" (
    echo [OK] Task installed and started. It runs at every logon with admin rights.
) else (
    echo [FAILED] See the message above.
)
echo.
pause
exit /b %RC%

#PSSTART#
$ErrorActionPreference = 'Stop'

$script = $env:DVORAK_SCRIPT
if (-not (Test-Path -LiteralPath $script)) {
    throw "Script not found: $script"
}

$candidates = @(
    'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe',
    'C:\Program Files\AutoHotkey\v2\AutoHotkey32.exe',
    "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe",
    "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey32.exe"
)
$ahk = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $ahk) {
    throw "AutoHotkey v2 was not found. Install AutoHotkey v2 from https://www.autohotkey.com/ and run this file again."
}

$me = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$taskName = 'Dvorak Layout'

$action    = New-ScheduledTaskAction -Execute $ahk -Argument ('"' + $script + '"')
$trigger   = New-ScheduledTaskTrigger -AtLogOn -User $me
$trigger.Delay = 'PT30S'
$principal = New-ScheduledTaskPrincipal -UserId $me -LogonType Interactive -RunLevel Highest
$settings  = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero)

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
Write-Host "  Task name   : $taskName"
Write-Host "  Interpreter : $ahk"
Write-Host "  Script      : $script"
Write-Host "  Logon delay : 30 seconds (lets WSL start)"

Start-ScheduledTask -TaskName $taskName
Start-Sleep -Seconds 2
$info = Get-ScheduledTask -TaskName $taskName | Get-ScheduledTaskInfo
Write-Host "  Last result : $($info.LastTaskResult)"
