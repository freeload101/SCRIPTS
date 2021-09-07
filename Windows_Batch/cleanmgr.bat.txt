:DELALLUSERS
echo %date% %time% INFO: Removing All users temp files
FOR /F "delims==" %%A IN ('DIR/B "C:\Users"') DO rd /s/q "C:\Users\%%A\AppData\Local\Microsoft\Windows\Temporary Internet Files\Content.IE5\"
FOR /F "delims==" %%A IN ('DIR/B "C:\Users"') DO rd /s/q "C:\Users\%%A\AppData\Local\History\"
FOR /F "delims==" %%A IN ('DIR/B "C:\Users"') DO rd /s/q "C:\Users\%%A\AppData\Local\Temp\"
FOR /F "delims==" %%A IN ('DIR/B "C:\Users"') DO rd /s/q "C:\Users\%%A\AppData\Roaming\Microsoft\Windows\Cookies\"
FOR /F "delims==" %%A IN ('DIR/B "C:\Users"') DO rd /s/q "C:\Users\%%A\AppData\Roaming\Microsoft\Windows\Recent\"
FOR /F "delims==" %%A IN ('DIR/B "C:\Users"') DO rd /s/q "C:\Users\%%A\Local Settings\Temporary Internet Files\"



:RUNCLEANMGR
echo %date% %time% INFO: Running windows cleanmgr 
FOR /F "tokens=* delims=" %%A in ('reg QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"') do (
REG ADD "%%A"  /v StateFlags0777 /t REG_DWORD /d 00000002 /f
)
cleanmgr /sagerun:777

