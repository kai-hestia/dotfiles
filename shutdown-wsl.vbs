' Hidden launcher used by the "Shutdown WSL" Start Menu shortcut.
' Runs `wsl.exe --shutdown` with no console window.
Option Explicit

Dim shell
Set shell = CreateObject("WScript.Shell")
shell.Run "wsl.exe --shutdown", 0, False
