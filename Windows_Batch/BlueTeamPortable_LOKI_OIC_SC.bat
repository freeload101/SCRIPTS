@echo off
echo '-----------------------------------------------------------------------------------------'
echo 'rmccurdy.com'
echo 'LOKI_SC (Single Click)'  
echo '-----------------------------------------------------------------------------------------'



cd %~dp0

CALL :CHECKADMIN
CALL :DLWGET
CALL :DLLOKI
CALL :UNZIPLOKI
CALL :UPDATELOKI
CALL :RUNLOKI
CALL :OPENLOGS
CALL :THEEND


:CHECKADMIN
echo %date% %time% INFO: Checking for admin ...
FOR /F "tokens=1,2*" %%V IN ('bcdedit') DO SET adminTest=%%V
IF (%adminTest%)==(Access) goto noAdmin
EXIT /B %ERRORLEVEL%



:DLWGET
echo %date% %time% INFO: Downloading wget via Powershell (May NOT be latest binary !)
powershell "(New-Object Net.WebClient).DownloadFile('https://eternallybored.org/misc/wget/1.20.3/64/wget.exe', '.\wget.exe')" > %temp%/null
EXIT /B %ERRORLEVEL%

:DLLOKI
echo %date% %time% INFO: Downloading LOKI
wget -q -U "rmccurdy.com" -q -P LOKI -e robots=off  -nd -r  "https://github.com/Neo23x0/Loki/releases/latest" --max-redirect 1 -l 1 -A "latest,loki_*.zip" -R '*.gz,release*.*' --regex-type pcre --accept-regex "loki_.*.zip"
EXIT /B %ERRORLEVEL%

:UNZIPLOKI
echo %date% %time% INFO: Extracting LOKI.zip
move .\LOKI\*.zip .\LOKI\LOKI.zip > %temp%/null
powershell "Expand-Archive .\LOKI\LOKI.zip -DestinationPath ." > %temp%/null
EXIT /B %ERRORLEVEL%

:UPDATELOKI
echo %date% %time% INFO: Updating LOKI sigs
cd  %~dp0\LOKI
loki-upgrader.exe --sigsonly
EXIT /B %ERRORLEVEL%

:RUNLOKI
echo %date% %time% INFO: Starting LOKI ...
cd  %~dp0\LOKI
loki.exe
EXIT /B %ERRORLEVEL%


:OPENLOGS
echo %date% %time% INFO: Complete opening log files
cd  "%~dp0\LOKI"
FOR /F "tokens=* delims=" %%A in ('dir /s/b loki_*.log') do (cmd /c notepad "%%A" ) 
EXIT /B %ERRORLEVEL%


:noAdmin
echo %date% %time% ERROR: You must run this script as an Administrator!
echo.
pause
exit

:THEEND
echo ALL DONE!
exit
 
