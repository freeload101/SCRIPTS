#InstallKeybdHook
#Persistent
#MaxThreadsPerHotkey 2
SetTimer, Check, 9000


; Left handed binds !

; copy
F9::send ^c

F10::
{
send,#v
}
return

;Alt Tab
F8:: Send ^!{Tab}	; brings up the Alt-Tab menu
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




// Toggle High Contrast
F12::
Toggle := !Toggle
loop
{
    If(toggle)
		vFlags := 0x1 ;on
		VarSetCapacity(HIGHCONTRAST, vSize, 0)
		NumPut(vSize, &HIGHCONTRAST, 0, "UInt") ;cbSize
		;HCF_HIGHCONTRASTON := 0x1
		NumPut(vFlags, &HIGHCONTRAST, 4, "UInt") ;dwFlags
		;SPI_SETHIGHCONTRAST := 0x43
		DllCall("user32\SystemParametersInfo", UInt,0x43, UInt,vSize, Ptr,&HIGHCONTRAST, UInt,0)
	If (!toggle)
		vFlags := 0x0 ;off
		vSize := A_PtrSize=8?16:12
		VarSetCapacity(HIGHCONTRAST, vSize, 0)
		NumPut(vSize, &HIGHCONTRAST, 0, "UInt") ;cbSize
		;HCF_HIGHCONTRASTON := 0x1
		NumPut(vFlags, &HIGHCONTRAST, 4, "UInt") ;dwFlags
		;SPI_SETHIGHCONTRAST := 0x43

		DllCall("user32\SystemParametersInfo", UInt,0x43, UInt,vSize, Ptr,&HIGHCONTRAST, UInt,0)
	 break
}
return

; FUNCTIONS 


; FUNCTIONS UNUSED

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


; use clipboard history
;%windir%\System32\cmd.exe /c "echo off | clip"
;wmic service where "name like '%%cbdhsvc_%%'" call stopservice
;wmic service where "name like '%%cbdhsvc_%%'" call startservice
