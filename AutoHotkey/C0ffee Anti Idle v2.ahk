; Complete rewrite for v2 ...



; Copy
!a::Copy()

; Paste
!s::send "{LCtrl Down}v{LCtrl Up}"


; Reload
^!r::ReloadScript()


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
return
