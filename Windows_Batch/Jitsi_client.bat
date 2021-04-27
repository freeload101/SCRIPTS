REM @echo off
setlocal enabledelayedexpansion

echo '-----------------------------------------------------------------------------------------'
echo 'rmccurdy.com ( jitsi client for windows installer  )'
echo 'ver 1.0a'
echo '-----------------------------------------------------------------------------------------'

CALL :INIT
CALL :CATCH


CALL :DLWGET
CALL :CATCH


CALL :DLJITSI
CALL :CATCH

CALL :END




:DLJITSI
(
echo %date% %time% INFO: Downloading latest Jitsi client
wget -U "rmccurdy.com"  -P jitsi  -e robots=off  -nd -r  "https://github.com/jitsi/jitsi-meet-electron/releases/latest" --max-redirect 1 -l 1 -A "latest,jitsi-meet.exe" -R '*.gz,release*.*' --regex-type pcre --accept-regex "jitsi-meet.exe"
.\jitsi\jitsi-meet.exe
)
EXIT /B %ERRORLEVEL%




:CATCH
IF %ERRORLEVEL% NEQ 0 (
echo %date% %time% ERROR: Something went wrong
pause
)
EXIT /B %ERRORLEVEL%


:DLWGET
echo %date% %time% INFO: Downloading wget via Powershell https://eternallybored.org/misc/wget/1.20.3/64/wget.exe (Warning: May NOT be latest binary !)
powershell "(New-Object Net.WebClient).DownloadFile('https://eternallybored.org/misc/wget/1.20.3/64/wget.exe', '.\wget.exe')" > %temp%/null
EXIT /B %ERRORLEVEL%



:INIT
(
cd "%~dp0"
rd /q/s jitsi
) 
EXIT /B %ERRORLEVEL%

:END
echo %date% %time% INFO: All done
