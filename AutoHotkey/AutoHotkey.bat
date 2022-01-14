@echo off
setlocal enabledelayedexpansion

echo '-----------------------------------------------------------------------------------------'
echo 'rmccurdy.com AutoHotkey Installer'
echo 'ver 1.0a'
echo '-----------------------------------------------------------------------------------------'

CALL :INIT
CALL :CATCH

CALL :CHECK
CALL :CATCH


CALL :END


:CHECK
if not exist "%~dp0wget.exe" (
	echo %date% %time% INFO: No wget.exe found
	CALL :DLWGET
	)
if not exist "%~dp0AHK\AutoHotkey.exe" (
	echo %date% %time% INFO: No AutoHotkey found
	CALL :DLAHK
		)
if not exist "%~dp0C0ffee Anti Idle.ahk" (
	echo %date% %time% INFO: AutoHotkey script not found
	cd "%~dp0"
	"%~dp0wget.exe"  "https://raw.githubusercontent.com/freeload101/SCRIPTS/master/AutoHotkey/C0ffee Anti Idle.ahk" )

if exist "%~dp0C0ffee Anti Idle.ahk" (
	echo %date% %time% INFO: Starting AutoHotkey
start ""	"%~dp0AHK\AutoHotkey.exe" "%~dp0C0ffee Anti Idle.ahk"
	)

EXIT /B %ERRORLEVEL%



:DLAHK
(
echo %date% %time% INFO: Downloading latest AutoHotkey
wget -U "rmccurdy.com"  -P AHK_BASE  -e robots=off  -nd -r  "https://github.com/Lexikos/AutoHotkey_L/releases/latest" --max-redirect 1 -l 1 -A "latest,*.exe" -R '*.gz,release*.*' --regex-type pcre --accept-regex ".*\.exe"
cd "%~dp0AHK_BASE"
rename "*.exe" "AutoHotkey.exe" 
echo %date% %time% INFO: Installing AutoHotkey
"%~dp0AHK_BASE\AutoHotkey.exe" /S /D="%~dp0AHK"
CALL :END
)
EXIT /B %ERRORLEVEL%




:CATCH
IF %ERRORLEVEL% NEQ 0 (
echo %date% %time% ERROR: Something went wrong
)
EXIT /B %ERRORLEVEL%


:DLWGET
echo %date% %time% INFO: Downloading wget via Powershell https://eternallybored.org/misc/wget/1.20.3/64/wget.exe (Warning: May NOT be latest binary !)
powershell "(New-Object Net.WebClient).DownloadFile('https://eternallybored.org/misc/wget/1.20.3/64/wget.exe', '.\wget.exe')" > %temp%/null
EXIT /B %ERRORLEVEL%



:INIT
(
cd "%~dp0"
taskkill /F /IM AutoHotkey.exe 2>> "log.txt"
rd /q/s "%~dp0AHK_BASE" 2>> "log.txt"
) 
EXIT /B %ERRORLEVEL%

:END
echo %date% %time% INFO: All done
exit