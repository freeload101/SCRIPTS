@echo off
setlocal enabledelayedexpansion

echo '-----------------------------------------------------------------------------------------'
echo 'rmccurdy.com ( BleachBit Downloader)'
echo 'ver 2.1'
echo '-----------------------------------------------------------------------------------------'




CALL :INIT

CALL :QUICKKILL
CALL :CATCH

CALL :RUNCLEANMGR
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





CHOICE /C YN /N /T 5 /D N /M "Securly Delete Files and free space on disk. This will take much longer to perform clean Y/N"
IF ERRORLEVEL 1 SET SECURE=YES
IF ERRORLEVEL 2 SET SECURE=NO
SET ERRORLEVEL=0

EXIT /B %ERRORLEVEL%


:RUNCLEANMGR
echo %date% %time% INFO: Running windows cleanmgr first
FOR /F "tokens=* delims=" %%A in ('reg QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"') do (
REG ADD "%%A"  /v StateFlags0777 /t REG_DWORD /d 00000002 /f
)
cleanmgr /sagerun:777
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
powershell  -command "& {$BBList = cmd /c BleachBit_console.exe -l ; $BBcmd = ".\BleachBit_console.exe -o --no-uac -c $BBList" }"
EXIT /B %ERRORLEVEL%



:RUNBBQUICK
echo %date% %time% INFO: Running Quick BleachBit/Updating INI file
cd .\BleachBit-Portable
echo %date% %time% INFO: Running BleachBit
BleachBit_console.exe  --update-winapp2 1>> output.log 2>&1
powershell  -command "& {$BBList = cmd /c BleachBit_console.exe -l ; $BBList -replace 'system.free_disk_space','' ;  $BBcmd = ".\BleachBit_console.exe --no-uac -c $BBList" }"
EXIT /B %ERRORLEVEL%



:QUICKKILL
# Quickkill
echo Downloading Quickkill"  
powershell "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/freeload101/SCRIPTS/master/Windows_Batch/quickkill.bat.txt', '.\quickkill.bat')" 

echo Running Quickkill 
cmd /c .\quickkill.bat


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
