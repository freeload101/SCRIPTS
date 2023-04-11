if not exist "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Startup.bat" (
copy Startup.bat "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
)
 

PowerShell -Command "Set-ExecutionPolicy Unrestricted"  


if not exist "%USERPROFILE%\AutoHotkey.ps1" (
::download install.ps1
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://github.com/freeload101/SCRIPTS/raw/master/AutoHotkey/AutoHotkey.ps1','%USERPROFILE%\AutoHotkey.ps1'))"

)
::run installer
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& "%USERPROFILE%\AutoHotkey.ps1""
