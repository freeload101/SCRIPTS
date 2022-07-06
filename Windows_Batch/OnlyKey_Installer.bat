#@echo off
Setlocal EnableDelayedExpansion EnableExtensions

echo '-----------------------------------------------------------------------------------------'
echo 'Onlykey Desktop Installer (no admin)'
echo 'ver 1.0a'
echo '-----------------------------------------------------------------------------------------'

CALL :INIT

CALL :DL7IP

CALL :CHECK

CALL :ONLYKEYDL

:INIT
(
	cd "%~dp0"
) 
EXIT /B 0



:DLWGET
echo %date% %time% INFO: Downloading wget via Powershell https://eternallybored.org/misc/wget/1.20.3/64/wget.exe (Warning: May NOT be latest binary !)
powershell "(New-Object Net.WebClient).DownloadFile('https://eternallybored.org/misc/wget/1.20.3/64/wget.exe', '.\wget.exe')" > %temp%/null
EXIT /B 0




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
EXIT /B 0


:DL7IP
(
	echo %date% %time% INFO: Downloading latest 7zip
	mkdir "%~dp07ZIP_BASE"
	wget  "https://sourceforge.net/projects/sevenzip/files/latest/download"  -A *.exe -O 7zip.exe
	move /Y 7zip.exe "%~dp07ZIP_BASE"
	cd %~dp07ZIP_BASE
	echo %date% %time% INFO: Installing 7zip
	set __COMPAT_LAYER=RUNASINVOKER 
	"%~dp07ZIP_BASE\7zip.exe" /S /D="%~dp07ZIP"
)
EXIT /B 0



:ONLYKEYDL
	echo %date% %time% INFO: Downloading Latest OnlyKey
	cd "%~dp0"
	wget -q -U "rmccurdy.com" -e robots=off  -nd -r  "https://github.com/trustcrypto/OnlyKey-App/releases/latest" --max-redirect 1 -l 1 -A "latest,*.exe" -R '*.gz,release*.*' --regex-type pcre --accept-regex ".*\.exe"
	cd "%~dp0"
	rename "*.exe" "OnlyKey.exe" 
	echo %date% %time% INFO: Extracting OnlyKey
	"%~dp07ZIP\7z.exe"   X -aoa  "%~dp0OnlyKey.exe" -o"%~dp0OnlyKey"
	start ""  "%~dp0OnlyKey\nw.exe"
EXIT /B 0
