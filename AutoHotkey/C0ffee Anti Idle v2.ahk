; Complete rewrite for v2 ...
InstallKeybdHook 

!d::
{
send "{LCtrl Down}t{LCtrl Up}"
}

 

; Copy
!a::Copy()

; SELECT ALLCOPY
!q::
{
send "{LCtrl Down}a{LCtrl Up}"
sleep 200
Copy()
}

; Paste
!s::Paste()

; Type Clipboard
!z::{
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
!x::Split3()
!c::Send " Refine the following message to make it more clear and concise using the personality MBTI Myers-Brigg personality ENFJ and tritype Enneagram 729. Be sure not to use any emojis at all in your response :"
!v::Send "https://calendly.com/rmccurdy1 to setup a call any time"

; Reload
^!r::ReloadScript()

;;;;;;; ADMIN / CONFIG 
; hibernate
!0::Run "C:\Windows\System32\shutdown.exe -h"
!F11::HighContrastOn()
!F12::HighContrastOff()


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
delay1 := "300"
ResizeAllWindowsHeight()

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
	return
}
