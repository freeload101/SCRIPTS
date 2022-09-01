@echo off
setlocal enabledelayedexpansion
echo ###############################################################################
echo rmccurdyDOTcom
echo This script will download and install a buncha stuff I use for base Windows builds
echo ###############################################################################

SET DIR=%~dp0%

:: Installing Droid Sans Mono Font for MobaXterm
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/DroidSansMono/complete/Droid Sans Mono Nerd Font Complete Mono Windows Compatible.otf','c:\windows\fonts\Droid Sans Mono Nerd Font Complete Mono Windows Compatible.otf'))"
REG add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "DroidSandMono NF" /t REG_SZ /d "Droid Sans Mono Nerd Font Complete Mono Windows Compatible.otf" /f

:: Disable Sleep,Lid and Power stuff
powercfg -restoredefaultschemes

:: On Battery
powercfg /SETDCVALUEINDEX SCHEME_CURRENT 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0

:: On AC Timeout
powercfg /SETACVALUEINDEX SCHEME_CURRENT 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0

:: On Battery lid
powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
:: On AC lid 
powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0

:: Disable sleep for everything
powercfg /x -hibernate-timeout-ac 0
powercfg /x -hibernate-timeout-dc 0
powercfg /x -disk-timeout-ac 0
powercfg /x -disk-timeout-dc 0
powercfg /x -monitor-timeout-ac 0
powercfg /x -monitor-timeout-dc 0
Powercfg /x -standby-timeout-ac 0
powercfg /x -standby-timeout-dc 0

:: Lock After Screensaver ( needs admin)
powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_NONE CONSOLELOCK 0
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_NONE CONSOLELOCK 0

:: Disable “This App is Preventing Shutdown or Restart” Screen 
reg add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f
reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d "1000" /f
reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "1000" /f
reg add "HKLM\System\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "1000" /f

CHOICE /C YN /N /T 5 /D N /M "Install Cygwin and optional Windows apps ? Y/N"
IF ERRORLEVEL 1 SET CYGWIN=YES
IF ERRORLEVEL 2 SET CYGWIN=NO
 
 
CHOICE /C YN /N /T 5 /D N /M "Run Debloat? Y/N"
IF ERRORLEVEL 1 SET DEBLOAT=YES
IF ERRORLEVEL 2 SET DEBLOAT=NO
 
SET ERRORLEVEL=0

IF "%DEBLOAT%" == "YES" (
CALL :DEBLOAT
) 

echo [+] Checking powershell version...
@powershell if ($PSVersionTable.PSVersion.Major -eq 5) {    Write-Host " [+] You are running PowerShell version 5"}else {    Write-Host " [+] This is version $PSVersionTable.PSVersion.Major Please update!!!";Start-Sleep -s 99 }


echo [+] Checking for admin ...
FOR /F "tokens=1,2*" %%V IN ('bcdedit') DO SET adminTest=%%V
IF (%adminTest%)==(Access) goto noAdmin

goto main1


CALL :theEnd


:DEBLOAT
echo [+] Downloading/Installing Win10Hardening_Debloat.ps1
::download install.ps1
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://github.com/freeload101/SCRIPTS/raw/master/Windows_Powershell_ps/Win10Hardening_Debloat.ps1','%DIR%Win10Hardening_Debloat.ps1'))"
::run installer
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%DIR%Win10Hardening_Debloat.ps1' %*"
EXIT /B %ERRORLEVEL%

:noAdmin
echo [+] You must run this script as an Administrator!
echo.
pause
exit
:theEnd


:main1
echo [+] Disabling PowerShell Executionpolicy
@powershell.exe   -Enc UwBlAHQALQBFAHgAZQBjAHUAdABpAG8AbgBQAG8AbABpAGMAeQAgAC0ARQB4AGUAYwB1AHQAaQBvAG4AUABvAGwAaQBjAHkAIABVAG4AcgBlAHMAdAByAGkAYwB0AGUAZAAgAC0ARgBvAHIAYwBlAA==

echo [+] Downloading/Installing chocolatey

::choco upgrade chocolatey
choco upgrade chocolatey -y

::download install.ps1
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://chocolatey.org/install.ps1','%DIR%install.ps1'))"
::run installer
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%DIR%install.ps1' %*"

set PATH=%PATH%;"C:\ProgramData\chocolatey\bin"
choco feature enable -n allowGlobalConfirmation

:: Licensed Chocolatey Pro 
mkdir "C:\ProgramData\chocolatey\license"
copy /y "%DIR%chocolatey.license.xml" "C:\ProgramData\chocolatey\license\chocolatey.license.xml"
 
choco upgrade chocolatey.extension

echo [+] Running Sync Check ?
choco list -lo



for %%x in (
	chocolateygui
	chromium
	irfanview
	irfanview-shellextension
	irfanviewplugins
	vlc	
	7zip
	mobaxterm
	notepadplusplus
	filezilla
) do (
	echo Installing:	%%x
	choco install %%x
	choco upgrade %%x
)


IF "%CYGWIN%" == "YES" (
CALL :CYGWIN
)


choco upgrade all -y

:: dirty hack to make updates autorun on boot Choco has AU script but its stupid comlicated (AU)
sc delete "Chocolatey_Update"
sc create "Chocolatey_Update"  binpath= "cmd /c start powershell.exe -nop -w hidden -c \"choco upgrade chocolatey -y\""
sc description Chocolatey_Update "Chocolatey_Update"
sc config Chocolatey_Update start= auto
net start Chocolatey_Update
EXIT /B %ERRORLEVEL%

:CYGWIN

:: more choco
echo [+] Installing additional choco apps 
for %%x in (
	openshot
	plexamp
	veracrypt
	libreoffice-fresh
	teracopy
) do (
	echo Installing:	%%x
	choco upgrade %%x
)


::cygwinportable
echo [+] Downloading/Installing Cygwin Portable
echo [+] Exit now if you do not want to install Cygwin
timeout /t 10
cd "%DIR%"
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://github.com/vegardit/cygwin-portable-installer/raw/main/cygwin-portable-installer.cmd','%DIR%cygwin-portable-installer.cmd'))"
cmd /c cygwin-portable-installer.cmd
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://github.com/transcode-open/apt-cyg/raw/master/apt-cyg','%DIR%\cygwin\bin\apt-cyg'))"
EXIT /B %ERRORLEVEL%

:theEnd

echo [+] All done!
pause
exit
