REM @echo off





CALL :INIT
CALL :CATCH
 

CALL :CHECKADMIN
CALL :CATCH



if %DSFINSTALL%==YES (
CALL :GODSF
CALL :CATCH
)
 
if %NAVDATAINSTALL%==YES (
CALL :NAVDATAINSTALL
CALL :CATCH
)


CALL :END

if not exist "%~dp0ORTHO4XP_EXTRACTED\README.md" (
REM https://drive.google.com/u/0/uc?id=1PWgp33gDUQbY3uZmYbTi3ccMPLIJMQAQ&export=download

CALL :ORTHO4XPDOWNLOAD

	if not exist "%~dp0utils\wget.exe" (
	CALL :DLWGET
	CALL :CATCH
	)
	
	
CALL :CATCH
)
 






:CHECKADMIN
echo %date% %time% INFO: Checking for admin ...
FOR /F "tokens=1,2*" %%V IN ('bcdedit') DO SET adminTest=%%V
IF (%adminTest%)==(Access) goto noAdmin
EXIT /B %ERRORLEVEL%



:INIT
cd "%~dp0"

CHOICE /C YN /N /T 5 /D N /M "Extract and install zip files in "%~dp0dsf" Y/N?"
IF ERRORLEVEL 1 SET DSFINSTALL=YES
IF ERRORLEVEL 2 SET DSFINSTALL=NO
set ERRORLEVEL=0

CHOICE /C YN /N /T 5 /D N /M "Extract and install US ONLY nav data ( dont if you are not sure)  in "%~dp0dsf" Y/N?"
IF ERRORLEVEL 1 SET NAVDATAINSTALL=YES
IF ERRORLEVEL 2 SET NAVDATAINSTALL=NO
set ERRORLEVEL=0



echo %date% %time% INFO: Setting utils path to "%~dp0utils"

if not exist "%~dp0utils" mkdir "%~dp0utils" 

REM TODO :need to fix %PATH% to have python after install ...(refresh %PATH% without exiting ... etc ...
path %PATH%;"%~dp0utils";C:\Python39\python.exe


REM TODO : get xplan path from registry ? MUST HAVE TRRAILING SLASHES
set XPLANEPATH=C:\xplane\
REM TODO :CHECK FOR XPLANE
REM TODO :use tokens to seproatee urls and ppowershell to download...
set DSFPATHS=""URL1";"URL2""
EXIT /B %ERRORLEVEL%



:GODSF



echo %date% %time% INFO: Setting up Paths...
if not exist "%XPLANEPATH%Custom Scenery\zzz_hd_global_scenary4" (
mkdir "%XPLANEPATH%Custom Scenery\zzz_hd_global_scenary4" 
)
if not exist "%XPLANEPATH%Custom Scenery\zzz_hd_global_scenary4\Earth nav data" (
mkdir "%XPLANEPATH%Custom Scenery\zzz_hd_global_scenary4\Earth nav data"  
)


echo %date% %time% INFO: Extracting dsf folder "%~dp0dsf"
cd "%~dp0dsf"
rd /q/s "%~dp0dsf\EXTRACT"
7z x  *.zip -oEXTRACT -y
cd  "%~dp0dsf\EXTRACT"
for /f "delims=" %%i IN ('dir /AD /b "%~dp0dsf\EXTRACT\"') do (
move "%%i" "%XPLANEPATH%Custom Scenery\zzz_hd_global_scenary4\Earth nav data" 
)

explorer "%XPLANEPATH%Custom Scenery\zzz_hd_global_scenary4\Earth nav data"
EXIT /B %ERRORLEVEL%



:DLWGET
echo %date% %time% INFO: Downloading wget via Powershell https://eternallybored.org/misc/wget/1.20.3/64/wget.exe (Warning: May NOT be latest binary !)
cd "%~dp0\utils"
powershell "(New-Object Net.WebClient).DownloadFile('https://eternallybored.org/misc/wget/1.20.3/64/wget.exe', '.\wget.exe')" > %temp%/null
EXIT /B %ERRORLEVEL%


:ORTHO4XPDOWNLOAD
midir  "%~dp0ORTHO4XP"
cd "%~dp0ORTHO4XP"

echo %date% %time% INFO: Downloading latest Ortho4XP
wget -q -U "rmccurdy.com" -q -P .\  -e robots=off  -nd -r  "https://github.com/oscarpilote/Ortho4XP/releases/latest" --max-redirect 1 -l 1 -A "latest,*.zip" -R '*.gz,release*.*' --regex-type pcre --accept-regex ".*.zip"
move .\*.zip .\ORTHO4XP.zip > %temp%/null
powershell "Expand-Archive .\ORTHO4XP.zip -DestinationPath ."  > %temp%/null

for /f "delims=" %%i IN ('dir /AD /b "%~dp0ORTHO4XP\"') do (
move "%%i" "%~dp0ORTHO4XP_EXTRACTED"
)
EXIT /B %ERRORLEVEL%


:DLPYTHON
REM Not needed because we have orthoXP binary...
choco install python -y --force
REM choco install jdk8 -y --force
REM choco install vcredist2017 -y --force
REM choco install python -y --force
REM choco install 7zip -y --force
)
EXIT /B %ERRORLEVEL%


:DLCHOCO
REM Not currently needed by anything in this script
SET DIR=%~dp0%

::download install.ps1
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://chocolatey.org/install.ps1','%DIR%install.ps1'))"
::run installer
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%DIR%install.ps1' %*"
EXIT /B %ERRORLEVEL%






:NAVDATAINSTALL
REM REFERENCE: 
REM https://forums.x-plane.org/index.php?/forums/topic/121327-faa-cifp/
REM https://www.youtube.com/watch?v=jybCVtg3VJY
REM www.simbrief.com ( for co route .fms format)
if not exist "%~dp0NAVDATAINSTALL" (
mkdir  "%~dp0NAVDATAINSTALL"
) else (
rd /q/s "%~dp0NAVDATAINSTALL"
mkdir  "%~dp0NAVDATAINSTALL"
)

cd "%~dp0NAVDATAINSTALL"

echo %date% %time% INFO: Downloading latest USA Navdata from FAA 
wget -q -U "rmccurdy.com" -P .\  -e robots=off  -nd -r  "https://www.faa.gov/air_traffic/flight_info/aeronav/digital_products/cifp/download/" --max-redirect 1 -l 1 -A "index.html,*.zip" -R '*.gz,release*.*' --regex-type pcre --accept-regex ".*.zip"  --span-hosts   --domains=www.faa.gov,aeronav.faa.gov  

for /f %%j in ('dir "%~dp0NAVDATAINSTALL\*.zip" /b/a-d/od/t:c') do set LAST1="%%j"
move "%LAST1%" .\NAVDATAINSTALL.zip > %temp%/null
powershell "Expand-Archive .\NAVDATAINSTALL.zip -DestinationPath ."  > %temp%/null
move /y FAACIFP18  "%XPLANEPATH%Custom Data\earth_424.dat"

if not exist "%XPLANEPATH%Custom Data\earth_424.dat" (
echo %date% %time% ERROR: can't find "%XPLANEPATH%Custom Data\earth_424.dat"
) 

if exist "%XPLANEPATH%\Aircraft\B737-800X\B738X_apt.dat" (
echo %date% %time% INFO: Removing old Zibo dat files  
del "%XPLANEPATH%\Aircraft\B737-800X\B738X_apt.dat"
del "%XPLANEPATH%\Aircraft\B737-800X\B738X_gate.dat"
del "%XPLANEPATH%\Aircraft\B737-800X\B738X_rnw.dat"
)

explorer "%XPLANEPATH%Custom Data\"
EXIT /B %ERRORLEVEL%



:BetterPushbackC
REM TODO:https://github.com/skiselkov/BetterPushbackC/releases
REM  https://github.com/skiselkov/BetterPushbackC/archive/master.zip
REM C:\xplane\Resources\plugins
IF %ERRORLEVEL% NEQ 0 (
echo %date% %time% INFO: Something went wrong
pause
exit
)
EXIT /B %ERRORLEVEL%



:CATCH
IF %ERRORLEVEL% NEQ 0 (
echo %date% %time% INFO: Something went wrong
pause
exit
)
EXIT /B %ERRORLEVEL%


:END
echo %date% %time% INFO: All done ...
pause
exit
