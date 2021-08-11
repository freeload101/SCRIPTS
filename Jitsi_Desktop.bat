@echo off
setlocal enabledelayedexpansion

echo '-----------------------------------------------------------------------------------------'
echo 'rmccurdy.com Jitsi Desktop Downloader
echo '-----------------------------------------------------------------------------------------'

REM 04/26/2021:  * added fallback to legacy if no file is output in 3 seconds .. ( can't really catch errors on start command without wonky scripting or writing to error files) Reference: https://stackoverflow.com/questions/29740883/how-to-redirect-error-stream-to-variable/38928461#38928461

CALL :INIT

 
CALL :DLWGET
CALL :CATCH

CALL :DLJITSI
CALL :CATCH

CALL :THEEND

:DLWGET
echo %date% %time% INFO: Downloading wget via Powershell https://eternallybored.org/misc/wget/1.20.3/64/wget.exe (Warning: May NOT be latest binary !)
powershell "(New-Object Net.WebClient).DownloadFile('https://eternallybored.org/misc/wget/1.20.3/64/wget.exe', '.\wget.exe')" > %temp%/null
EXIT /B %ERRORLEVEL%
 
 
:CATCH
IF %ERRORLEVEL% NEQ 0 (
echo %date% %time% ERROR: Something went wrong
pause
)
EXIT /B %ERRORLEVEL%

:INIT
cd "%~dp0"
EXIT /B %ERRORLEVEL%

 
:DLJITSI
echo %date% %time% INFO: Downloading latest Jitsi
del jitsi-meet.exe
wget  -U "rmccurdy.com"   -e robots=off  -nd -r  "https://github.com/jitsi/jitsi-meet-electron/releases" --max-redirect 1 -l 1 -A "latest,*.exe" -R '*.gz,release*.*' --regex-type pcre --accept-regex ".*.exe"
start jitsi-meet.exe

EXIT /B %ERRORLEVEL%


:THEEND
echo %date% %time% INFO: All done!
pause
exit
