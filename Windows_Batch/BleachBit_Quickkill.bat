@echo off
setlocal enabledelayedexpansion

echo '-----------------------------------------------------------------------------------------'
echo 'rmccurdy.com ( BleachBit Downloader)'
echo 'ver 2.0a'
echo '-----------------------------------------------------------------------------------------'




CALL :INIT

CALL :QUICKKILL
CALL :CATCH

CALL :DLWGET
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





CHOICE /C YN /N /T 5 /D Y /M "Securly Delete Files and free space on disk. This will take much longer to perform clean Y/N"
IF ERRORLEVEL 1 SET SECURE=YES
IF ERRORLEVEL 2 SET SECURE=NO
SET ERRORLEVEL=0

EXIT /B %ERRORLEVEL%
  
:DLWGET
echo %date% %time% INFO: Downloading wget via Powershell https://eternallybored.org/misc/wget/1.20.3/64/wget.exe (Warning: May NOT be latest binary !)
powershell "(New-Object Net.WebClient).DownloadFile('https://eternallybored.org/misc/wget/1.20.3/64/wget.exe', '.\wget.exe')" > %temp%/null
EXIT /B %ERRORLEVEL%

:DLBB
echo %date% %time% INFO: Downloading BleachBit
wget -q -U "rmccurdy.com"    -e robots=off  -nd -r  "https://download.bleachbit.org/BleachBit-4.4.0-portable.zip" --max-redirect 1 -l 1 -A "*.zip" -R '*.gz,release*.*' --regex-type pcre --accept-regex ".*.zip"
powershell "(Expand-Archive .\BleachBit-4.4.0-portable.zip -DestinationPath . -Force)"
EXIT /B %ERRORLEVEL%

:RUNBB
echo %date% %time% INFO: Running Secure BleachBit/Updating INI file
cd .\BleachBit-Portable
echo %date% %time% INFO: Running BleachBit
BleachBit_console.exe  --update-winapp2 >>  1>> output.log 2>&1
powershell  -command "& {$BBList = cmd /c BleachBit_console.exe -l ; $BBcmd = "C:\DELETE\BleachBit-Portable\BleachBit_console.exe -o --no-uac -c $BBList" }"
EXIT /B %ERRORLEVEL%



:RUNBBQUICK
echo %date% %time% INFO: Running Quick BleachBit/Updating INI file
cd .\BleachBit-Portable
echo %date% %time% INFO: Running BleachBit
BleachBit_console.exe  --update-winapp2 1>> output.log 2>&1
powershell  -command "& {$BBList = cmd /c BleachBit_console.exe -l ; $BBList -replace 'system.free_disk_space','' ; $BBcmd = "C:\DELETE\BleachBit-Portable\BleachBit_console.exe --no-uac -c $BBList" }"
EXIT /B %ERRORLEVEL%


:QUICKKILL
echo %date% %time% INFO: Killing all tasks not in whitelist
CD /D "%~DP0"
SET Exclusions=CSFalconContainer.exe CSFalconService.exe SecurityHealthService.exe SecurityHealthSystray.exe cmd.exe explorer.exe taskmgr.exe svchost.exe conhost.exe find.exe lsass.exe dwm.exe  sihost.exe fontdrvhost.exe ctfmon.exe  tasklist.exe dllhost.exe lsaiso.exe

SET tmpfl=%~n0tmp.dat
IF EXIST "%tmpfl%" DEL /F /Q "%tmpfl%"
IF EXIST "output.log" DEL /F /Q "output.log"
SET Exclusions=%Exclusions% taskkill.exe tasklist.exe

SETLOCAL ENABLEDELAYEDEXPANSION
FOR /F "DELIMS=: TOKENS=2" %%A IN ('TASKLIST    /FO LIST ^| FIND /I "Image name:"') DO (
    SET var=%%~A
    SET var=!var: =!
    ECHO !var! | FINDSTR /I /V "%Exclusions%">>"%tmpfl%"
)
FOR /F "USEBACKQ TOKENS=*" %%A IN ("%tmpfl%") DO (
	rem DEBUG ECHO KILLING %%~A	
	rem DEBUG ping -n 1 -w 1 123.123.123.123 > %temp%\null
sc stop "TrustedInstaller"    1>> output.log 2>&1

sc config TrustedInstaller binPath= "cmd /c TASKKILL /F  /IM %%~A"    1>> output.log 2>&1

echo killing %%~A  1>> output.log 2>&1

echo killing %%~A  as Trustedinstaller 
sc start "TrustedInstaller"   1>> output.log 2>&1

echo killing %%~A  as current user
TASKKILL /F  /IM %%~A 1>> output.log 2>&1


REM dont remove this or things will go wrong...it will fix the service back
sc config TrustedInstaller binPath= "C:\Windows\servicing\TrustedInstaller.exe"   1>> output.log 2>&1
sc config TrustedInstaller binPath= "C:\Windows\servicing\TrustedInstaller.exe"  1>> output.log 2>&1
)
DEL /F /Q "%tmpfl%"c
EXIT /B %ERRORLEVEL%

:THEEND
echo %date% %time% INFO: All done!

reg add "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell"  /v "BagMRU Size" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"  /v "DisableThumbnailCache" /t REG_DWORD /d 1 /f

 
taskkill /im explorer.exe /f 
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify" /v IconStreams /f 
reg delete "HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify" /v PastIconsStream /f 
start "Shell Restarter" /d "%systemroot%" /i /normal explorer.exe


pause
exit
