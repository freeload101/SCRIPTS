#InstallKeybdHook
#Persistent
#MaxThreadsPerHotkey 2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  MAIN 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Initialize profiles

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Setup profile based on IP address
objWMIService := ComObjGet("winmgmts:{impersonationLevel = impersonate}!\\.\root\cimv2")
colItems := objWMIService.ExecQuery("Select * from Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")._NewEnum
while colItems[objItem]
	{
		IPAddress := % objItem.IPAddress[0]
		If InStr(IPAddress, "10.76.")
			{
			Message("IPAddress: " . IPAddress . " Loading Work Home Profile")
			SetTimer, AntiIdleNoEnter, 900, 0
			ProfileSet:=1
			Hotkey, Enter, Off
			Hotkey, NumpadEnter, Off
			SwapMouseButton(0)
			HighContrastOn()
			break
			}

		else If InStr(IPAddress, "192.168.20.12")
			{
			Message("IPAddress: " . IPAddress . " Loading Work Home Profile")
			SetTimer, AntiIdleNoEnter, 900, 0
			ProfileSet:=1
			Hotkey, Enter, Off
			Hotkey, NumpadEnter, Off
			SwapMouseButton(0)
			HighContrastOn()			
			break
			}

		else If InStr(IPAddress, "10.206.")
			{
			Message("IPAddress: " . IPAddress . " Loading Work Office Profile")
			SetTimer, AntiIdleNoEnter, 900, 0
			ProfileSet:=1
			Hotkey, Enter, Off
			Hotkey, NumpadEnter, Off
			SwapMouseButton(1)
			HighContrastOn()
			break
			}
	}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Fallback setting for NOT MY COMPUTER to idle and revert back any settings

if ProfileSet != 1
{

Message("Setting profile for unknown system?")

SetTimer, AntiIdleUnknown, 900, 0
SwapMouseButton(1)

}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; KEY BINDS !!! 

; Close Window Alt+w
F8::^w
return

; Copy
F9::send ^c
return

; Fancy pants paste
F10::
{
send,#v
}
return

; Alt Tab sort of 
F11:: Send !{Tab}	; brings up the Alt-Tab menu
F12:: Send {Alt Down}{Shift Down}{Tab}{Alt Up}{Shift Up}	; brings up the Alt-Tab menu backaward

!F11::HighContrastOn()
!F12::HighContrastOff()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Anti idle binding enter key to prevent sending of clipboard or sensitive data
AntiIdleNoEnter:
{
	if (A_TimeIdle > 58000)
	{
		SendF22()
		Hotkey, Enter, On
		Hotkey, NumpadEnter, On
	}	
}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Anti idle Normal 
AntiIdle()
{
	if (A_TimeIdle > 58000)
	{
		SendF22()
	}
}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Anti idle Unknown Computer (not mine)
AntiIdleUnknown()
{
	if (A_TimeIdle > 58000)
	{
		SendF22()
	}
	if (A_TimeIdle > 900000)
	{
		SetNormal()
	}
}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Sends F22 to anti idle
SendF22()
{
Send,{F22}
}
return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FUNCTIONS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Get IP address functions use to load 'profiles' based on IP address

;Display the networks public IP
GetPublicIP() {
    HttpObj := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    HttpObj.Open("GET","https://www.google.com/search?q=what+is+my+ip&num=1")
    HttpObj.Send()
    RegexMatch(HttpObj.ResponseText,"Client IP address: ([\d\.]+)",match)
    Return match1
}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Unbinds Enter key
Enter::Message("Press F1 Key to Stop")
NumpadEnter::Message("Press F1 Key to Stop")
Hotkey, Enter, Off
Hotkey, NumpadEnter, Off

F1::
{
Hotkey, Enter, Off
Hotkey, NumpadEnter, Off
return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Refresh all windows (F5)
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



; SwapMouseButton(0)   ; Right-Hand
; SwapMouseButton(1)   ; Left-Hand
SwapMouseButton(Swap)
{
    DllCall("user32.dll\SwapMouseButton", "UInt", Swap)
}

HighContrastOn()
{
	vFlags := 0x1 ;on
	vSize := A_PtrSize=8?16:12
	VarSetCapacity(HIGHCONTRAST, vSize, 0)
	NumPut(vSize, &HIGHCONTRAST, 0, "UInt") ;cbSize
	;HCF_HIGHCONTRASTON := 0x1
	NumPut(vFlags, &HIGHCONTRAST, 4, "UInt") ;dwFlags
	;SPI_SETHIGHCONTRAST := 0x43
	DllCall("user32\SystemParametersInfo", UInt,0x43, UInt,vSize, Ptr,&HIGHCONTRAST, UInt,0)
}
return

HighContrastOff()
{
	vFlags := 0x0 ;off
	vSize := A_PtrSize=8?16:12
	VarSetCapacity(HIGHCONTRAST, vSize, 0)
	NumPut(vSize, &HIGHCONTRAST, 0, "UInt") ;cbSize
	;HCF_HIGHCONTRASTON := 0x1
	NumPut(vFlags, &HIGHCONTRAST, 4, "UInt") ;dwFlags
	;SPI_SETHIGHCONTRAST := 0x43
	DllCall("user32\SystemParametersInfo", UInt,0x43, UInt,vSize, Ptr,&HIGHCONTRAST, UInt,0)
}
return

SetNormal()
{

HighContrastOff()
SwapMouseButton(0)

}
return


Message(Message)
{
TrayTip, "%Message%" ," ",10, 1
tooltip, "%Message%",0,0
msgbox,0,, 	"%Message%",5

;DEBUG msgbox, "%Message%"
sleep, 5000
tooltip,
}


