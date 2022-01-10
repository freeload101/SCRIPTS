#InstallKeybdHook
#Persistent
SetTimer, Check, 9000


; Left handed binds !

; copy
F9::send ^c

; use clipboard history
;%windir%\System32\cmd.exe /c "echo off | clip"
;wmic service where "name like '%%cbdhsvc_%%'" call stopservice
;wmic service where "name like '%%cbdhsvc_%%'" call startservice


F10::
{
send,#v
}
return

;Alt Tab
F12:: Send ^!{Tab}	; brings up the Alt-Tab menu
return


;unbinds Enter key
F1::
Hotkey, Enter, Off
Hotkey, NumpadEnter, Off
tooltip,
return


; anti idle binding enter key to prevent sending of clipboard or sensitive data
; it would be nice to have a way to prevent 'all' input but for F1 key etc ..
Check:
IfGreater, A_TimeIdle, 240000,{
; notify how to turn on the enter key
SendF22()
Enter::tooltip,"Press F1 Key to Stop"
NumpadEnter::tooltip,"Press F1 Key to Stop"

}

;disableds enter and sends F22 to anti idle
SendF22()
{
Hotkey, Enter, On
Hotkey, NumpadEnter, On

Send,{F22}
}



; Focus all windows and press F5 to stay logged in.. does not really work but intresting to keep if needed for other stuff
ClickyClick()
{
WinGet windows, List
	Loop %windows%
	{
	id := windows%A_Index%
	WinGetTitle wt, ahk_id %id%
	r .= wt . "`n"
	settitlematchmode,2
	if (wt != "")
	{
	WinActivate,%wt%
	sleep,500
	Send,^{F5}
	;tooltip,%wt%
	}
	CoordMode, Mouse, window
	}
}
return
