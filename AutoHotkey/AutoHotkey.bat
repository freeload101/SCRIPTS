@echo off
Setlocal EnableDelayedExpansion EnableExtensions

echo '-----------------------------------------------------------------------------------------'
echo 'rmccurdy.com AutoHotkey Installer'
echo 'ver 1.2a'
echo '-----------------------------------------------------------------------------------------'

CALL :INIT
CALL :CATCH

CALL :CHECK
CALL :CATCH


CALL :END



:CHECK
if exist "%~dp0wget.exe" (
 	set "WGETPATH=%~dp0wget.exe"
 	)
if exist "c:\windows\system32\wget.exe" (
	set "WGETPATH=c:\windows\system32\wget.exe"
	)	

if not "!WGETPATH!"=="" (
    echo %date% %time% INFO: wget.exe found !WGETPATH!
) else (
	echo %date% %time% INFO: No wget.exe found
	CALL :DLWGET
	set "WGETPATH=%~dp0wget.exe"
)




if not exist "%~dp0AHK\AutoHotkey.exe" (
	echo %date% %time% INFO: No AutoHotkey found
	CALL :DLAHK
	)
if not exist "%~dp0C0ffee Anti Idle.ahk" (
	echo %date% %time% INFO: AutoHotkey script "%~dp0C0ffee Anti Idle.ahk" not found downloading 
	cd "%~dp0"
	"%WGETPATH%" -q "https://raw.githubusercontent.com/freeload101/SCRIPTS/master/AutoHotkey/C0ffee Anti Idle.ahk" 
	)

if exist "%~dp0C0ffee Anti Idle.ahk" (
	echo %date% %time% INFO: Starting AutoHotkey with "%~dp0C0ffee Anti Idle.ahk"
start ""	"%~dp0AHK\AutoHotkey.exe" "%~dp0C0ffee Anti Idle.ahk"
	)
EXIT /B %ERRORLEVEL%




REM Don't need 7zip if I can bypass admin prompt with compat layer set
:DL7IP
(
echo %date% %time% INFO: Downloading latest 7zip
mkdir "%~dp07ZIP_BASE"
wget  "https://sourceforge.net/projects/sevenzip/files/latest/download"  -A *.exe -O 7zip.exe
move /Y 7zip.exe "%~dp07ZIP_BASE"
cd %~dp07ZIP_BASE
echo %date% %time% INFO: Installing 7zip
set __COMPAT_LAYER=RUNASINVOKER 
"%~dp07ZIP_BASE\7zip.exe /S /D="%~dp07ZIP"
)


EXIT /B %ERRORLEVEL%


:DLAHK
(
echo %date% %time% INFO: Downloading latest AutoHotkey
wget -q -U "rmccurdy.com"  -P AHK_BASE  -e robots=off  -nd -r  "https://github.com/Lexikos/AutoHotkey_L/releases/latest" --max-redirect 1 -l 1 -A "latest,*.exe" -R '*.gz,release*.*' --regex-type pcre --accept-regex ".*\.exe"
cd "%~dp0AHK_BASE"
rename "*.exe" "AutoHotkey.exe" 
echo %date% %time% INFO: Installing AutoHotkey
set __COMPAT_LAYER=RUNASINVOKER 
"%~dp0AHK_BASE\AutoHotkey.exe"  /S /D="%~dp0AHK"
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
EXIT /B 0

:END
echo %date% %time% INFO: All done
timeout /t 2
exit 
