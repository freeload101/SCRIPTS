@echo off
echo ###############################################################################
echo rmccurdyDOTcom
echo This script will download and install a buncha stuff I use for base Windows builds
echo ###############################################################################

SET DIR=%~dp0%

timeout /t 5 >> %temp%\null


 


echo [+] Checking powershell version...
@powershell if ($PSVersionTable.PSVersion.Major -eq 5) {    Write-Host " [+] You are running PowerShell version 5"}else {    Write-Host " [+] This is version $PSVersionTable.PSVersion.Major Please update!!!";Start-Sleep -s 99 }


echo [+] Checking for admin ...
FOR /F "tokens=1,2*" %%V IN ('bcdedit') DO SET adminTest=%%V
IF (%adminTest%)==(Access) goto noAdmin

goto main1

:noAdmin
echo [+] You must run this script as an Administrator!
echo.
pause
exit
:theEnd


:main1
echo [+] Disabling PowerShell Executionpolicy
@powershell.exe   -Enc UwBlAHQALQBFAHgAZQBjAHUAdABpAG8AbgBQAG8AbABpAGMAeQAgAC0ARQB4AGUAYwB1AHQAaQBvAG4AUABvAGwAaQBjAHkAIABVAG4AcgBlAHMAdAByAGkAYwB0AGUAZAAgAC0ARgBvAHIAYwBlAA==
   
echo [+] Downloading/Installing Win10Hardening_Debloat.ps1
::download install.ps1
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://github.com/freeload101/SCRIPTS/raw/master/Windows_Powershell_ps/Win10Hardening_Debloat.ps1','%DIR%Win10Hardening_Debloat.ps1'))"
::run installer
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%DIR%Win10Hardening_Debloat.ps1' %*"
 
echo [+] Downloading/Installing chocolatey

::choco upgrade chocolatey
choco upgrade chocolatey -y

::download install.ps1
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://chocolatey.org/install.ps1','%DIR%install.ps1'))"
::run installer
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%DIR%install.ps1' %*"

set PATH=%PATH%;"C:\ProgramData\chocolatey\bin"
choco feature enable -n allowGlobalConfirmation

for %%x in (
	discord
	irfanview
	libreoffice
	gimp
	openshot
	plexamp
	vlc
	zoom
	veracrypt
	7zip
	chromium
	irfanview
	irfanview-shellextension
	irfanviewplugins
 mobaxterm
 chromium
	notepadplusplus
 filezilla
 libreoffice-fresh
 
) do (
	echo Installing:	%%x
	choco install %%x
)
 
choco upgrade all -y

:: dirty hack to make updates autorun on boot Choco has AU script but its stupid comlicated (AU)
sc delete "Chocolatey_Update"
sc create "Chocolatey_Update"  binpath= "cmd /c start powershell.exe -nop -w hidden -c \"choco upgrade chocolatey -y\""
sc description Chocolatey_Update "Chocolatey_Update"
sc config Chocolatey_Update start= auto
net start Chocolatey_Update





::cygwinportable
echo [+] Downloading/Installing Cygwin Portable
echo [+] Exit now if you do not want to install Cygwin
timeout /t 10
cd "%DIR%"
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://github.com/vegardit/cygwin-portable-installer/raw/main/cygwin-portable-installer.cmd','%DIR%cygwin-portable-installer.cmd'))"
cmd /c cygwin-portable-installer.cmd
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://github.com/transcode-open/apt-cyg/raw/master/apt-cyg','%DIR%\cygwin\bin\apt-cyg'))"


:theEnd

echo [+] All done!
pause
exit
