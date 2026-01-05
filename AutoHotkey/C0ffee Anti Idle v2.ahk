; 10:28 AM 12/30/2025: added Alt+ F10 to resize / move all windows if things go crazy 
; 4:26 AM 10/18/2025: Rewrite to fix alt issues now using Caps Lock A/S
; Complete rewrite for v2 ...


InstallKeybdHook 
; Disable CapsLock toggle FIRST
SetCapsLockState "AlwaysOff"

CapsLock & t::
{
send "{LCtrl Down}t{LCtrl Up}"
}

; Then define the combinations

CapsLock & w::
{
send "{LCtrl Down}w{LCtrl Up}"
}


CapsLock & a::
{
Copy()
}

CapsLock & s::
{
Paste()
}

; Mouse buttons as backup
XButton1::
{
Copy()
}

XButton2::
{
Paste()
}

 

; Reload
^!r::ReloadScript()

;;;;;;; ADMIN / CONFIG 
; hibernate
!0::Run "C:\Windows\System32\shutdown.exe -h -f"
!F11::HighContrastOn()
!F12::HighContrastOff()
!F10::MoveAndResizeAllWindows()


CapsLock & q::
{
MoveAndResizeAllWindows()
}
 
; Type Clipboard
CapsLock & z::{
    Sleep 1000
    ; Store clipboard content
    text := A_Clipboard

    ; Send each character with 1 second delay
    for char in StrSplit(text)
    {
        Send char
        Sleep 50
    }
}

; common input
CapsLock & x::{
MoveAndResizeAllWindows()
Split3()
}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; STARTUP STARTUP STARTUP STARTUP STARTUP STARTUP STARTUP STARTUP STARTUP STARTUP STARTUP 
SetTimer AntiIdleUnknown, 65000, 0

;;;;;;;;;;;;;;;;;;;;;
;Sends F22 to anti idle
;;;;;;;;;;;;;;;;;;;;

SendF22()
{
send "{F22}"
}


;Setup keyboard state
;;;;;;;;;;;;;;;;;;;;

WipeKbdState()
{
send "{alt up}"
send "{ctrl up}"
SetNumLockState False
SetNumLockState false
}

 


AntiIdleUnknown()
{
	if (A_TimeIdle > 65000)
	{
		SendF22()
	}
}

;;;;;;;;;;;;;;;;;;;;
; Copy Function Advanced
;;;;;;;;;;;;;;;;;;;;

Copy()
	{
		if WinActive("ahk_class TMobaXtermForm")
		{
			send "^{Ins}"
		}
		if WinActive("ahk_class VirtualConsoleClass")
		{
			send "^{Ins}"
		}
		else
		{
			send "^c"
		}
	}

;;;;;;;;;;;;;;;;;;;;
; Paste Function Advanced
;;;;;;;;;;;;;;;;;;;;

Paste()
	{
		if WinActive("ahk_class TMobaXtermForm")
		{
			send "{LShift Down}{Ins}{LShift Up}"
		}
		else
		{
			send "{LCtrl Down}v{LCtrl Up}"
		}
	}


;;;;;;;;;;;;;;;;;;;;
; Reloads the script so you don't have to rightclick reload etc
;;;;;;;;;;;;;;;;;;;;

ReloadScript()
{
	Reload
	SendMessage(0x1A, 0, StrPtr("Environment"), 0xFFFF)
}

;;;;;;;;;;;;;;;;;;;;
; Turn on High contrast
;;;;;;;;;;;;;;;;;;;;

HighContrastOn()
{
	file := "C:\Windows\Resources\Ease of Access Themes\hc2.theme"
	if FileExist(file) {
		Run "C:\Windows\Resources\Ease of Access Themes\hc2.theme"
		sleep 1000
		run "taskkill /im systemsettings.exe /f"
	}
}

HighContrastOff()
{
	file := "C:\Windows\Resources\Themes\Light.theme"
	if FileExist(file) {
		Run "C:\Windows\Resources\Themes\Light.theme"
		sleep 1000
		run "taskkill /im systemsettings.exe /f"
	} 
	
	file := "C:\Windows\Resources\Themes\aero.theme"
	if FileExist(file) {
		Run "C:\Windows\Resources\Themes\aero.theme"
		sleep 1000
		run "taskkill /im systemsettings.exe /f"
	}
	
}

;;;;;;;;;;;;;;;;;;;;
; Cycle through all windows and set their height to 1400
;;;;;;;;;;;;;;;;;;;;


ResizeAllWindowsHeight()
{
    ; Get list of all windows
    windowList := WinGetList()
    resizedCount := 0

    for hwnd in windowList
    {
        try
        {
            ; Skip if window doesn't exist or is minimized/maximized
            if !WinExist("ahk_id " hwnd) || WinGetMinMax("ahk_id " hwnd) != 0
                continue

            ; Skip windows with no title (usually system/special windows)
            if !WinGetTitle("ahk_id " hwnd)
                continue

            ; Get current position and size
            WinGetPos &x, &y, &width, &height, "ahk_id " hwnd

            ; Skip windows with no dimensions
            if !height || !width
                continue

            ; Resize window (maintain width, change height to 1440)
            WinMove x, 0, width, 1440, "ahk_id " hwnd
            resizedCount++
        }
        catch as e
        {
            ; Skip windows that can't be resized
            continue
        }
    }
}


;;;;;;;;;;;;;;;;;;;;
; Split into 3 and make the current window the center panel and reset whatever ... 
;;;;;;;;;;;;;;;;;;;;

Split3()
{
tooltip "SPLIT3"
WipeKbdState

delay1 := "300"
;ResizeAllWindowsHeight()

sleep delay1

	Send "{LWin down}"
	sleep delay1
	send "z"
	sleep delay1
	Send "{LWin Up}"
	sleep delay1
	send "9"
	sleep delay1
	send "2"
	sleep delay1
	Send "{enter}"
	tooltip ""
	return

}


;;;;;;;;;;;;;;;;;;;;
; Updateded POC : Cycle through all windows and set their height to 1400
;;;;;;;;;;;;;;;;;;;;

MoveAndResizeAllWindows()
{
    ; Target dimensions
    targetX := 1344
    targetY := 0
    targetW := 2527
    targetH := 1447

    ; Get list of all windows
    windowList := WinGetList()
    resizedCount := 0

    for hwnd in windowList
    {
        try
        {
            ; Skip if window doesn't exist or is minimized/maximized
            if !WinExist("ahk_id " hwnd) || WinGetMinMax("ahk_id " hwnd) != 0
                continue

            ; Skip windows with no title (usually system/special windows)
            if !WinGetTitle("ahk_id " hwnd)
                continue

            ; Get current dimensions to verify window is valid
            WinGetPos &x, &y, &width, &height, "ahk_id " hwnd

            ; Skip windows with no dimensions
            if !height || !width
                continue

            ; Move and resize window to target dimensions
            WinMove targetX, targetY, targetW, targetH, "ahk_id " hwnd
            resizedCount++
        }
        catch as e
        {
            ; Skip windows that can't be resized
            continue
        }
    }

    return resizedCount
}



