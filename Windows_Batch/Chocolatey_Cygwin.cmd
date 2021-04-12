@echo off
echo ###############################################################################
echo rmccurdyDOTcom
echo This script will download and install a buncha stuff I use for base Windows builds
echo ###############################################################################

SET DIR=%~dp0%

timeout /t 5
echo [+] Checking powershell version...
@powershell if ($PSVersionTable.PSVersion.Major -eq 5) {    Write-Host " [+] You are running PowerShell version 5"}else {    Write-Host " [+] This is version $PSVersionTable.PSVersion.Major Please update!!!";Start-Sleep -s 99 }


echo [+] Checking for admin ...
FOR /F "tokens=1,2*" %%V IN ('bcdedit') DO SET adminTest=%%V
IF (%adminTest%)==(Access) goto noAdmin

:noAdmin
echo [+] You must run this script as an Administrator!
echo.
pause
exit
:theEnd





echo [+] Downloading/Installing RemoveW10Bloat.bat
::download install.ps1
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://rmccurdy.com/.scripts/Windowd_10_Debloat_security/RemoveW10Bloat.bat','%DIR%RemoveW10Bloat.bat'))"
::run installer
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%DIR%RemoveW10Bloat.bat' %*"


echo [+] Downloading/Installing remove-default-apps.ps1
::download install.ps1
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://rmccurdy.com/.scripts/Windowd_10_Debloat_security/remove-default-apps.ps1','%DIR%remove-default-apps.ps1'))"
::run installer
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%DIR%remove-default-apps.ps1' %*"
 
set PATH=%PATH%;"C:\ProgramData\chocolatey\bin"

choco install notepadplusplus -y 
choco install irfanview -y
choco install irfanview-shellextension -y
choco install irfanviewplugins -y 
choco install libreoffice-fresh -y

choco install veracrypt -y
choco install 7zip -y
choco install chromium -y
choco install vlc -y
 
 


echo [+] Downloading/Installing Cygwin Portable

::download install.ps1
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://chocolatey.org/install.ps1','%DIR%install.ps1'))"
::run installer
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%DIR%install.ps1' %*"


::cygwinportable
cd "%DIR%"
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://raw.githubusercontent.com/vegardit/cygwin-portable-installer/master/cygwin-portable-installer.cmd','%DIR%cygwin-portable-installer.cmd'))"
cmd /c cygwin-portable-installer.cmd
