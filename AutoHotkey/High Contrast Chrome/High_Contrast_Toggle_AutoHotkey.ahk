#MaxThreadsPerHotkey 2

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
