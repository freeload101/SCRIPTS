@echo off

SET DIR=%~dp0%

::download install.ps1
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://chocolatey.org/install.ps1','%DIR%install.ps1'))"
::run installer
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%DIR%install.ps1' %*"

choco install notepadplusplus -y
choco install irfanview -y
choco install irfanview-shellextension -y
choco install libreoffice-fresh -y

choco install veracrypt -y
choco install 7zip -y
choco install chromium -y
choco install vlc -y
 

::cygwinportable
cd "%DIR%"
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://raw.githubusercontent.com/vegardit/cygwin-portable-installer/master/cygwin-portable-installer.cmd','%DIR%cygwin-portable-installer.cmd'))"
cmd /c cygwin-portable-installer.cmd



