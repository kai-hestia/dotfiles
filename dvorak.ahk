#Requires AutoHotkey v2.0
#SingleInstance Force

;==============================================================
; Tray icon + master on/off switch
;   Ctrl+Alt+D  = enable / disable the whole Dvorak remap
;   Right-click the tray icon for the same, plus Reload / Exit
;==============================================================
Enabled := true
LShiftUsed := false
RShiftUsed := false
SpaceHeld := false
SpaceUsed := false

SetupTray()

ToggleDvorak(*) {
	global Enabled
	Enabled := !Enabled
	if Enabled {
		A_IconTip := "Dvorak layout - active`nCtrl+Alt+D = disable"
		TrayTip("Active - Dvorak remap is on.", "Dvorak layout")
	} else {
		A_IconTip := "Dvorak layout - DISABLED`nCtrl+Alt+D = enable"
		TrayTip("Disabled - keyboard is normal now.`nCtrl+Alt+D to enable.", "Dvorak layout")
	}
}

SetupTray() {
	A_TrayMenu.Delete()
	A_TrayMenu.Add("Enable / Disable Dvorak (Ctrl+Alt+D)", ToggleDvorak)
	A_TrayMenu.Default := "Enable / Disable Dvorak (Ctrl+Alt+D)"
	A_TrayMenu.Add()
	A_TrayMenu.Add("Reload", (*) => Reload())
	A_TrayMenu.Add("Exit", (*) => ExitApp())
	A_IconTip := "Dvorak layout - active`nCtrl+Alt+D = disable"
}

; Always active, even while the remap is disabled.
^!d::ToggleDvorak()

; Everything below only applies while Enabled is true.
#HotIf Enabled

;==============================================================
; Special keys
;==============================================================
*CapsLock::HandleCapsLock()   ; hold = Ctrl, tap = Esc
*LShift::HandleLShift()       ; hold = Shift, tap = (
*RShift::HandleRShift()       ; hold = Shift, tap = [
*Space::HandleSpace()         ; hold = Alt,   tap = space
*Enter::HandleEnter()         ; hold = Ctrl,  tap = Enter
*NumpadEnter::HandleEnter("NumpadEnter")
~*LButton::MouseGuard()
~*RButton::MouseGuard()
~*MButton::MouseGuard()

;==============================================================
; Dvorak remap
;==============================================================
*q::Send("{Blind}'")
*w::Send("{Blind},")
*e::Send("{Blind}.")
*r::Send("{Blind}p")
*t::Send("{Blind}y")
*y::Send("{Blind}f")
*u::Send("{Blind}g")
*i::Send("{Blind}c")
*o::Send("{Blind}r")
*p::Send("{Blind}l")
*a::Send("{Blind}a")
*s::Send("{Blind}o")
*d::Send("{Blind}e")
*f::Send("{Blind}u")
*g::Send("{Blind}i")
*h::Send("{Blind}d")
*j::Send("{Blind}h")
*k::Send("{Blind}t")
*l::Send("{Blind}n")
*;::Send("{Blind}s")
*z::Send("{Blind};")
*x::Send("{Blind}q")
*c::Send("{Blind}j")
*v::Send("{Blind}k")
*b::Send("{Blind}x")
*n::Send("{Blind}b")
*m::Send("{Blind}m")
*,::Send("{Blind}w")
*.::Send("{Blind}v")
*/::Send("{Blind}z")
*'::Send("{Blind}-")
*-::Send("{Blind}[")
*=::Send("{Blind}]")
*[::Send("{Blind}/")
*]::Send("{Blind}=")

;==============================================================
; Alt+`  toggle the terminal (clone of the Hammerspoon Alacritty
;        binding: focused -> minimize, running -> focus, else launch)
;        Targets WezTerm; see ToggleTerminal() to change it.
;==============================================================
!`::ToggleTerminal()

;==============================================================
; GNU readline-style cursor movement -- WINDOW-SCOPED: active only
; while a Windows Terminal window is focused, so it can't shadow
; browser shortcuts like Ctrl+F (Find).
;   C-x = hold CapsLock (Ctrl),  M-x = hold Space (Alt)
;   Command names are readline's; the keys are the Dvorak letters
;   you type, with the physical key in parentheses.
;
;   C-a  beginning-of-line -> Home        (physical A)
;   C-e  end-of-line       -> End         (physical D)
;   C-b  backward-char     -> Left        (physical N)
;   C-f  forward-char      -> Right       (physical Y)
;   C-p  previous-line     -> Up          (physical R)
;   C-n  next-line         -> Down        (physical L)
;   M-b  backward-word     -> Ctrl+Left   (physical N)
;   M-f  forward-word      -> Ctrl+Right  (physical Y)
;==============================================================
#HotIf Enabled && WinActive("ahk_exe WindowsTerminal.exe")

^a::Send("{Home}")
^d::Send("{End}")
^n::Send("{Left}")
^y::Send("{Right}")
^r::Send("{Up}")
^l::Send("{Down}")
!n::Send("^{Left}")
!y::Send("^{Right}")

#HotIf

;==============================================================
; Handlers
;==============================================================
HandleCapsLock() {
	Send("{Blind}{LCtrl DownR}")
	KeyWait("CapsLock")
	tapped := (A_PriorKey = "CapsLock")
	Send("{Blind}{LCtrl Up}")
	if tapped
		Send("{Blind}{Esc}")
}

HandleLShift() {
	global LShiftUsed
	Send("{Blind}{LShift DownR}")
	KeyWait("LShift")
	tapped := (A_PriorKey = "LShift") && !LShiftUsed
	Send("{Blind}{LShift Up}")
	if tapped
		Send("{Blind}(")
	LShiftUsed := false
}

HandleRShift() {
	global RShiftUsed
	Send("{Blind}{RShift DownR}")
	KeyWait("RShift")
	tapped := (A_PriorKey = "RShift") && !RShiftUsed
	Send("{Blind}{RShift Up}")
	if tapped
		Send("{Blind}[")
	RShiftUsed := false
}

HandleSpace() {
	global SpaceHeld, SpaceUsed
	SpaceHeld := true
	Send("{Blind}{LAlt DownR}")
	KeyWait("Space")
	tapped := (A_PriorKey = "Space") && !SpaceUsed
	Send("{Blind}{LAlt Up}")
	if tapped
		Send("{Blind}{Space}")
	SpaceHeld := false
	SpaceUsed := false
}

HandleEnter(keyName := "Enter") {
	; Don't fight CapsLock if it is already holding Ctrl.
	ownCtrl := !GetKeyState("LCtrl")
	if ownCtrl
		Send("{Blind}{LCtrl DownR}")
	KeyWait(keyName)
	tapped := (A_PriorKey = keyName)
	if ownCtrl
		Send("{Blind}{LCtrl Up}")
	if tapped
		Send("{Blind}{" . keyName . "}")
}

MouseGuard(*) {
	global LShiftUsed, RShiftUsed, SpaceHeld, SpaceUsed
	if GetKeyState("LShift")
		LShiftUsed := true
	if GetKeyState("RShift")
		RShiftUsed := true
	if SpaceHeld
		SpaceUsed := true
}

ToggleTerminal() {
	static termExe := "wezterm-gui.exe"
	if WinActive("ahk_exe " . termExe) {
		WinMinimize("ahk_exe " . termExe)
	} else if WinExist("ahk_exe " . termExe) {
		WinActivate("ahk_exe " . termExe)
	} else {
		; Standard install location; falls back to PATH.
		exe := EnvGet("ProgramFiles") . "\WezTerm\wezterm-gui.exe"
		if FileExist(exe)
			Run('"' . exe . '"')
		else
			Run("wezterm-gui.exe")
	}
}
