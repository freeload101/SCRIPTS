REM @echo off
setlocal enabledelayedexpansion

echo '-----------------------------------------------------------------------------------------'
echo 'rmccurdy.com'
echo 'ZTL_Update_Tool'
echo 'ver .01a'
echo '-----------------------------------------------------------------------------------------'


REM SET ENV VARABLES

rem https://github.com/freeload101/SCRIPTS/blob/master/Windows_Batch/Youtube-dl-ffmpeg-aria2c-updater-downloader.bat
rem New-Item -ItemType SymbolicLink -Path "Link" -Target "Target"

rem C:\Users\Administrator\Documents\VRC\
REM https://vrc.rosscarlson.dev/download.shtml
rem https://vrc.rosscarlson.dev/download.php?file=VRCSetup1.2.6.exe


REM FATURE
REM * Makes ZTL software portable and easy to Backup/Modify/Update!
REM * Backup VRC Configs
REM * Downloads Latest VRC

REM USAGE:
REM Copy any existing VRC config files from %USERPROFILE%\Documents\VRC\ into .\vrc_config

CALL :INIT
CALL :CATCH

CALL :CHKWGET
CALL :CATCH

CALL :CHKVRC
CALL :CATCH

CALL :THEEND


REM ----------------------------------------------------------------- FUNCTIONS


:INIT
cd "%~dp0"
set ZTLPATH=%~dp0

	if not exist ".\vrc_config" (
	mkdir ".\vrc_config"
	mkdir ".\vrc_config\Documents"
	)
	
	if not exist ".\vrc" (
	mkdir ".\vrc"
	)
	
	if not exist ".\tools" (
	mkdir ".\tools"
	)
	
for /f "delims=" %%a in ('wmic OS Get localdatetime ^| find "."') do set DateTime=%%a

set Yr=%DateTime:~0,4%
set Mon=%DateTime:~4,2%
set Day=%DateTime:~6,2%
set Hr=%DateTime:~8,2%
set Min=%DateTime:~10,2%
set Sec=%DateTime:~12,2%

set BACKUPDATE=%Yr%-%Mon%-%Day%_(%Hr%-%Min%-%Sec%)

	
	
EXIT /B %ERRORLEVEL%

:CHKWGET
	if not exist ".\tools\wget.exe" (
	CALL :DLWGET
	CALL :CATCH
	)
EXIT /B %ERRORLEVEL%


:DLWGET
	echo %date% %time% INFO: Downloading wget via Powershell https://eternallybored.org/misc/wget/1.20.3/64/wget.exe (Warning: May NOT be latest binary !)
	powershell "(New-Object Net.WebClient).DownloadFile('https://eternallybored.org/misc/wget/1.20.3/64/wget.exe', '.\tools\wget.exe')" > %temp%/null
EXIT /B %ERRORLEVEL%


:CHKVRC
	if not exist ".\vrc\vrc.exe" (
	CALL :DLVRC
	CALL :CATCH
	)
EXIT /B %ERRORLEVEL%

:DLVRC
REM CHECK UPDATE FLAG
REM BACKUP CONFIG %USERPROFILE%\Documents
REM BACKUP CONFIG vrc_config

del ".\tools\*VRCSetup*.exe
del ".\tools\download*.*

echo %date% %time% INFO: Downloading latest VRC
wget  -q -U "rmccurdy.com" -q -P tools  -e robots=off  -nd -r  "https://vrc.rosscarlson.dev/download.shtml" --max-redirect 1 -l 1 -R '*shared*,*lgpl*,autobuild-*.*' --regex-type pcre --accept-regex ".*VRCSetup.*.exe"  
CHOICE /T 1 /C y /CS /D y > %temp%/null
FOR /F "tokens=*" %%A in ('dir /b /s *VRCSetup*.exe') do (rename "%%A" "VRCSetup.exe")

if exist  "c:\%USERNAME%\Documents\VRC\VRC.ini" (
echo %date% %time% INFO: Backing up existing c:\%USERNAME%\Documents\VRC 
xcopy /Y /E  /I /Q    "c:\%USERNAME%\Documents\VRC" "c:\%USERNAME%\Documents\VRC%BACKUPDATE%"
)

if exist  ".\vrc_config\VRC.ini" (
echo %date% %time% INFO: Backing up existing .\vrc_config
xcopy /Y /E  /I /Q    ".\vrc_config" ".\vrc_config_%BACKUPDATE%"
)

echo %date% %time% INFO: Installing VRC to %ZTLPATH%vrc1
.\tools\VRCSetup.exe /S /D=%ZTLPATH%vrc


echo 'cd %~dp0' > START_VRC.bat
echo 'set USERPROFILE=%~dp0vrc_config' >> START_VRC.bat
echo '.\vrc\vrc.exe' >> START_VRC.bat 



EXIT /B %ERRORLEVEL%


:CATCH
IF %ERRORLEVEL% NEQ 0 (
echo %date% %time% ERROR: Something went wrong
pause
)
EXIT /B %ERRORLEVEL%

:THEEND
echo %date% %time% INFO: All done!
REM pause
REM exit
