@echo off
setlocal enabledelayedexpansion

echo '-----------------------------------------------------------------------------------------'
echo 'rmccurdy.com ( BleachBit Downloader)'
echo '-----------------------------------------------------------------------------------------'

CALL :INIT

CALL :QUICKKILL
CALL :CATCH

CALL :DELALLUSERS
CALL :CATCH

CALL :RUNCLEANMGR
CALL :CATCH
 
CALL :DLBB
CALL :CATCH

IF "%SECURE%" == "YES" (
CALL :RUNBB
CALL :CATCH
CALL :THEEND
)

CALL :RUNBBQUICK
CALL :CATCH

CALL :THEEND



:CATCH
IF %ERRORLEVEL% NEQ 0 (
echo %date% %time% ERROR: Something went wrong
pause
)
EXIT /B %ERRORLEVEL%

:INIT
cd "%~dp0"
taskkill /F /IM "bleachbit_console.exe" 2> %temp%/null





CHOICE /C YN /N /T 5 /D N /M "Securly Delete Files and free space on disk. This will take much longer to perform clean Y/N"
IF ERRORLEVEL 1 SET SECURE=YES
IF ERRORLEVEL 2 SET SECURE=NO
SET ERRORLEVEL=0

EXIT /B %ERRORLEVEL%


:RUNCLEANMGR
echo %date% %time% INFO: Running windows cleanmgr first
FOR /F "tokens=* delims=" %%A in ('reg QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"') do (
REG ADD "%%A"  /v StateFlags0777 /t REG_DWORD /d 00000002 /f > %temp%/null
)
cleanmgr /sagerun:777
EXIT /B %ERRORLEVEL%


:DELALLUSERS
echo %date% %time% INFO: Removing All users temp files
FOR /F "delims==" %%A IN ('DIR/B "C:\Users"') DO rd /s/q "C:\Users\%%A\AppData\Local\Microsoft\Windows\Temporary Internet Files\Content.IE5\" 1>> output.log 2>&1
FOR /F "delims==" %%A IN ('DIR/B "C:\Users"') DO rd /s/q "C:\Users\%%A\AppData\Local\History\" 1>> output.log 2>&1
FOR /F "delims==" %%A IN ('DIR/B "C:\Users"') DO rd /s/q "C:\Users\%%A\AppData\Local\Temp\" 1>> output.log 2>&1
FOR /F "delims==" %%A IN ('DIR/B "C:\Users"') DO rd /s/q "C:\Users\%%A\AppData\Roaming\Microsoft\Windows\Cookies\" 1>> output.log 2>&1
FOR /F "delims==" %%A IN ('DIR/B "C:\Users"') DO rd /s/q "C:\Users\%%A\AppData\Roaming\Microsoft\Windows\Recent\" 1>> output.log 2>&1
FOR /F "delims==" %%A IN ('DIR/B "C:\Users"') DO rd /s/q "C:\Users\%%A\Local Settings\Temporary Internet Files\" 1>> output.log 2>&1
EXIT /B %ERRORLEVEL%


:DLBB
echo %date% %time% INFO: Downloading BleachBit
powershell "(New-Object Net.WebClient).DownloadFile('https://download.bleachbit.org/BleachBit-4.4.0-portable.zip', '.\BleachBit-4.4.0-portable.zip')" 
powershell "(Expand-Archive .\BleachBit-4.4.0-portable.zip -DestinationPath . -Force)"
EXIT /B %ERRORLEVEL%


:RUNBB
echo %date% %time% INFO: Running Secure BleachBit/Updating INI file
cd .\BleachBit-Portable
echo %date% %time% INFO: Running BleachBit
BleachBit_console.exe  --update-winapp2 1>> output.log 2>&1
powershell  -command "& {$BBList = cmd /c BleachBit_console.exe -l ; $BBcmd = ".\BleachBit_console.exe -o --no-uac --debug -c $BBList" }"
EXIT /B %ERRORLEVEL%



:RUNBBQUICK
echo %date% %time% INFO: Running Quick BleachBit/Updating INI file
cd .\BleachBit-Portable
echo %date% %time% INFO: Running BleachBit
BleachBit_console.exe  --update-winapp2 1>> output.log 2>&1
powershell  -command "& {$BBList = cmd /c BleachBit_console.exe -l ; $BBList = $BBList -replace 'system.free_disk_space','' ;  $BBcmd = ".\BleachBit_console.exe --no-uac --debug -c $BBList" }"
EXIT /B %ERRORLEVEL%



:QUICKKILL
echo %date% %time% INFO: Downloading/Running Quickkill.bat
powershell "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/freeload101/SCRIPTS/master/Windows_Batch/quickkill.bat.txt', '.\quickkill.bat')" 
start /W "quickkill" CALL .\quickkill.bat
EXIT /B %ERRORLEVEL%

:THEEND
echo %date% %time% INFO: All done!

reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell"  /v "BagMRU Size" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"  /v "DisableThumbnailCache" /t REG_DWORD /d 1 /f

 
taskkill /im explorer.exe /f 
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify" /v IconStreams /f 
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify" /v PastIconsStream /f 
start "Shell Restarter" /d "%systemroot%" /i /normal explorer.exe

 exit
