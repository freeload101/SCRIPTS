#InstallKeybdHook
#Persistent
SetTimer, Check, 9000

# This script will lock the Enter key on idle and keep the system from going to sleep
# Press the F1 key to reenable the Enter key
# script also has code to focus Each window and press F5 to 'refresh' websites to keep you logged in ( does not always work as some services want you to POST data to keep alive etc )

Enter::tooltip,"Press F1 Key to Stop"
NumpadEnter::tooltip,"Press F1 Key to Stop"

F1::
Hotkey, Enter, Off
Hotkey, NumpadEnter, Off

tooltip,

return

Check:
IfGreater, A_TimeIdle, 240000,{
	;ShowDesktop()
	SendF22()
}

SendF22()
{
Hotkey, Enter, On
Hotkey, NumpadEnter, On

Send,{F22}
}




ShowDesktop()
{
	;ClickyClick() ;too noisy does not really work with all browser sessions
	Send, {LWin Down}
	Sleep, 500
	Send, r
	Sleep, 500
	Send, d
	Sleep, 156
	Send, {LWin Up}
}

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
