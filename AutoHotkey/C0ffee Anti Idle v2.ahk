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
SetTimer AntiIdleUnknown, 58000, 0

;;;;;;;;;;;;;;;;;;;;;
;Sends F22 to anti idle
;;;;;;;;;;;;;;;;;;;;

SendF22()
{
send "{F22}"
}

AntiIdleUnknown()
{
	if (A_TimeIdle > 58000)
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
; Split into 3 and make the current window the center panel and reset whatever ... 
;;;;;;;;;;;;;;;;;;;;

Split3()
{
	 
	Send "{LWin down}"
	sleep 200
	send "z"
	sleep 200
	Send "{LWin Up}"
	send "z"
	sleep 200
	send "9"
	sleep 200
	send "2"
	return
}
