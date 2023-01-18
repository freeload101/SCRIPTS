; Complete rewrite for v2 ...

; Copy
!a::Copy()

; Paste
!s::send "{LCtrl Down}v{LCtrl Up}"

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
	;C:\Windows\Resources\Themes\Light.theme
	;start "" "C:\Windows\Resources\Ease of Access Themes\hc1.theme" & timeout /t 3 & taskkill /im "systemsettings.exe" /f
	Run "`"C:\Windows\Resources\Ease of Access Themes\hc1.theme`""
	sleep 1000
	run "taskkill /im systemsettings.exe /f"
}

HighContrastOff()
{
	;C:\Windows\Resources\Themes\Light.theme
	;start "" "C:\Windows\Resources\Ease of Access Themes\hc1.theme" & timeout /t 3 & taskkill /im "systemsettings.exe" /f
	Run "C:\Windows\Resources\Themes\Light.theme"
	sleep 1000
	run "taskkill /im systemsettings.exe /f"
}
