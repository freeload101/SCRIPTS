; Complete rewrite for v2 ...

; keep closing remote tabs !
^w::
{
sleep 100
return
}

^t::
{
sleep 100
return
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
Send A_Clipboard
send "{Ctrl Up}{Alt Up}"
} 

; common input
!x::Send "Robert.mccurdy@newellco.com"
!c::Send "Refine the following message to make it more clear and concise:"
!v::Send "https://outlook.office365.com/book/Mccurdy@Newellco.onmicrosoft.com to setup a call any time"

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
