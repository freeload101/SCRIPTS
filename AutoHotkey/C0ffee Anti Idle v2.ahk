; Complete rewrite for v2 ...

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
!s::send "{LCtrl Down}v{LCtrl Up}"

; Type Clipboard
!z::Send  A_Clipboard

; Type Clipboard
!x::Send "Robert.mccurdy@newellco.com"

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
		else
		{
			send "^c"
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
	Run "`"C:\Windows\Resources\Ease of Access Themes\hc2.theme`""
	sleep 5000
	run "taskkill /im systemsettings.exe /f"
}

HighContrastOff()
{
	Run "C:\Windows\Resources\Themes\Light.theme"
	sleep 5000
	run "taskkill /im systemsettings.exe /f"
}
