#InstallKeybdHook
#Persistent
#MaxThreadsPerHotkey 2
SetTitleMatchMode RegEx

; Todo: 
; * make Close Tab check if the current window still exist if it does try ^m or taskkill ?
;;;;;;;;;;;;;;;;;;;;
; Main Code Block
;;;;;;;;;;;;;;;;;;;;

LoadProfile()
HotkeyOff()
send,{LCtrl Up}
send,{Alt Up}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;KEY BINDS !!! 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Enter::Message("Press F1 Key to Stop")
NumpadEnter::Message("Press F1 Key to Stop")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;LEFT SIDE OF KEYBOARD
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!F1::HotkeyOff() 


;;;;;; COPY PASTE
; Select All Copy
!q::{
send,{LCtrl Down}a{LCtrl Up}
sleep,500
Copy()
}

; Cut
!w::send,{LCtrl Down}x{LCtrl Up}

; Copy
!a::Copy()

; Paste
!s::send,{LCtrl Down}v{LCtrl Up}

; Fancy pants paste
; broken becase of alt being held !d::FancyPantsPaste()

; Type Clipboard
!z::SendInput, %Clipboard%

;;;;;;; WINDOW MANAGMENT
# can't use numbers or anything thats not a special key ... typing delay is too slow so 12345 ends up looking like 1 & 2 ...

; Alt Tab sort of 
;1 & 2:: Send !{Tab}	; brings up the Alt-Tab menu
;1 & 3:: Send {Alt Down}{Shift Down}{Tab}{Alt Up}{Shift Up}	; brings up the Alt-Tab menu backaward
; Alt F4!
;1 & 4::CloseWindow()

; Chrome Tabs Move
;2 & 3::^+tab
;2 & 4::^tab
; Close Tab Alt+w
;2 & 5::^w

; Dictate
;3 & 4::#h


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;RIGHT SIDE OF KEYBOARD ( USE RIGHT SIDE IF YOU DON'T NEED THE MOUSE SOON BEFORE/AFTER OR IF YOU ARE GOING TO BE TYPING 44)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;; COMMON HOTKEYS 

; Ctrl + F (find)
;7 & f::^f

;;;;;;; ADMIN / CONFIG 
; hibernate
!0::RunWait, %comspec% /c "C:\Windows\System32\shutdown.exe -h"
!F11::HighContrastOn()
!F12::HighContrastOff()

!F9::SwapMouseButton(0) 
!F10::SwapMouseButton(1)

; Reload
^!r::ReloadScript()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;
;Sends F22 to anti idle
;;;;;;;;;;;;;;;;;;;;

SendF22()
{
Send,{F22}
}
return

FancyPantsPaste()
{
	send,{LWin Down}v
	sleep,10000
	send,{LWin Up}
}


;;;;;;;;;;;;;;;;;;;;
;Anti idle binding enter key to prevent sending of clipboard or sensitive data
;;;;;;;;;;;;;;;;;;;;

AntiIdleNoEnter:
{


	if (A_TimeIdle > 900000)
	{
		SendF22()
		Hotkey, Enter, On
		Hotkey, NumpadEnter, On
	}	
}
return

;;;;;;;;;;;;;;;;;;;;
;Anti idle Normal 
;;;;;;;;;;;;;;;;;;;;

AntiIdle()
{
	if (A_TimeIdle > 58000)
	{
		SendF22()
	}
}
return

;;;;;;;;;;;;;;;;;;;;
;Anti idle Unknown Computer (not mine)
;;;;;;;;;;;;;;;;;;;;

AntiIdleUnknown()
{
	if (A_TimeIdle > 58000)
	{
		SendF22()
	}
;this will never trigger ..
;	if (A_TimeIdle > 900000)
;	{
;		SetNormal()
;	}

}
return




; --------------------------------------------------- JEE_WinGetCtlClassNNRegEx FUNCTION
JEE_WinGetCtlClassNNRegEx(hWnd, vClassRegEx, vNum:=1)
{
	if !hWnd
		WinGet, hWnd, ID, A
	vCount := 0
	WinGet, vCtlList, ControlList, % "ahk_id " hWnd
	Loop, Parse, vCtlList, `n
	{
		vCtlClassNN := A_LoopField
		ControlGet, hCtl, Hwnd,, % vCtlClassNN, % "ahk_id " hWnd
		WinGetClass, vCtlClass, % "ahk_id " hCtl
		if RegExMatch(vCtlClass, vClassRegEx)
			vCount++
		if (vCount = vNum)
			return vCtlClassNN
	}
}



;----------------------------------------------------------------- Click_By_Control_Text FUNCTION
Click_By_Control_Text(String1,exitloopflag){
WinGet, ActiveControlList, ControlList, A
Loop, Parse, ActiveControlList, `n
{


ControlGetPos, x, y, w, h, %A_LoopField%, Audio For VATSIM Client
ControlGetText, theText, %A_LoopField% , Audio For VATSIM Client

 

;ToolTip,
;        (LTrim
;         A_LoopField: %A_LoopField%
;		  theText:	%theText%
;        )

		if (theText = String1)
		{
		MouseMove,%X%,%Y%
		Click
		}
if (exitloopflag == "true")
{
return
}
}
}
return


;;;;;;;;;;;;;;;;;;;;
;Setup profile based on IP address
;;;;;;;;;;;;;;;;;;;;

LoadProfile()

{
objWMIService := ComObjGet("winmgmts:{impersonationLevel = impersonate}!\\.\root\cimv2")
colItems := objWMIService.ExecQuery("Select * from Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")._NewEnum
while colItems[objItem]
	{
		IPAddress := % objItem.IPAddress[0]
		If InStr(IPAddress, "10.76.")
			{
			Message("IPAddress: " . IPAddress . " Loading Work Home Profile")
			;SetTimer, AntiIdleNoEnter, 900000, 0
			ProfileSet:=1
			Hotkey, Enter, Off
			Hotkey, NumpadEnter, Off
			;SwapMouseButton(0)
			HighContrastOff()
			break
			}

		else If InStr(IPAddress, "192.168.20.12")
			{
			Message("IPAddress: " . IPAddress . " Loading Work Home Profile")
			;SetTimer, AntiIdleNoEnter, 60000, 0
			ProfileSet:=1
			Hotkey, Enter, Off
			Hotkey, NumpadEnter, Off
			;SwapMouseButton(0)
			HighContrastOff()
			break
			}


		else If InStr(IPAddress, "192.168.3.17")
			{
			Message("IPAddress: " . IPAddress . " Loading Game Profile")
			;SetTimer, AntiIdleNoEnter, 60000, 0
			ProfileSet:=1
			Hotkey, Enter, Off
			Hotkey, NumpadEnter, Off
			SwapMouseButton(0)
			HighContrastOff()
			break
			}

		else If InStr(IPAddress, "10.206.")
			{
			Message("IPAddress: " . IPAddress . " Loading Work Office Profile")
			;SetTimer, AntiIdleNoEnter, 60000, 0
			ProfileSet:=1
			Hotkey, Enter, Off
			Hotkey, NumpadEnter, Off
			SwapMouseButton(0)
			HighContrastOff()
			break
			}
	
	}

;;;;;;;;;;;;;;;;;;;;
;Fallback setting for NOT MY COMPUTER to idle and revert back any settings
;;;;;;;;;;;;;;;;;;;;

	if ProfileSet != 1
	{
	Message("Setting profile for unknown system?")
	SetTimer, AntiIdleUnknown, 58000, 0
	Hotkey, Enter, Off
	Hotkey, NumpadEnter, Off
	SwapMouseButton(0)
	HighContrastOff()
	
	}
}

;;;;;;;;;;;;;;;;;;;;
;Get IP address functions use to load 'profiles' based on IP address
;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;
;Display the networks public IP
;;;;;;;;;;;;;;;;;;;;

GetPublicIP() {
    HttpObj := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    HttpObj.Open("GET","https://www.google.com/search?q=what+is+my+ip&num=1")
    HttpObj.Send()
    RegexMatch(HttpObj.ResponseText,"Client IP address: ([\d\.]+)",match)
    Return match1
}
return


;;;;;;;;;;;;;;;;;;;;
;Refresh all windows (F5)
;;;;;;;;;;;;;;;;;;;;

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
return
}


;;;;;;;;;;;;;;;;;;;;
; SwapMouseButton(0) or 1
;;;;;;;;;;;;;;;;;;;;

SwapMouseButton(Swap)
{
	; SwapMouseButton(0)   ; Right-Hand
	; SwapMouseButton(1)   ; Left-Hand
	DllCall("user32.dll\SwapMouseButton", "UInt", Swap)
}

;;;;;;;;;;;;;;;;;;;;
; Turn on High contrast
;;;;;;;;;;;;;;;;;;;;

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


;;;;;;;;;;;;;;;;;;;;
; Turn off high contrast ( some colors are off in windows ) maybe apply theme on / off to fix
;;;;;;;;;;;;;;;;;;;;

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

;;;;;;;;;;;;;;;;;;;;
; Sets everything back to normal
;;;;;;;;;;;;;;;;;;;;

SetNormal()
{

HighContrastOff()
SwapMouseButton(0)

}
return

;;;;;;;;;;;;;;;;;;;;
; Easy way to Send message
;;;;;;;;;;;;;;;;;;;;

Message(Message)
{
;SoundBeep, 750, 500
TrayTip, "%Message%" ," ",10, 1
tooltip, "%Message%",300,300
;msgbox,0,, 	"%Message%",3 ; Do not use because of it changes focus ..
sleep, 5000
tooltip,
}

;;;;;;;;;;;;;;;;;;;;
; Close window Alt+F4 but says no to save notepad prompt
;;;;;;;;;;;;;;;;;;;;

CloseWindow()
{
send,!{f4}
;#IfWinActive, ahk_class Notepad
;ifWinActive Notepad ahk_class #32770
WinActivate, Notepad ahk_class #32770

	{
		sleep,20
		send,n
	}
}
return

;;;;;;;;;;;;;;;;;;;;
; Reloads the script so you don't have to rightclick reload etc
;;;;;;;;;;;;;;;;;;;;

ReloadScript()
{
Reload
Message("Reloading")
}
return



;;;;;;;;;;;;;;;;;;;;
; Copy Function Advanced
;;;;;;;;;;;;;;;;;;;;

Copy()
{
if WinActive("ahk_class TMobaXtermForm"){
send,^{Ins}
}
else
{
send,^c
}




sleep,500
tooltip,


}
return

;;;;;;;;;;;;;;;;;;;;
; Hotkey Off Function
;;;;;;;;;;;;;;;;;;;;
HotkeyOff()
{
Hotkey, Enter, Off
Hotkey, NumpadEnter, Off
}
