@echo off
echo ###############################################################################
echo rmccurdyDOTcom
echo This script will download and install sysmon and winlogbeat!
echo Usage: update the winogbeat URL and the WINLOGBEAT CONFIG FILE section
echo ###############################################################################
timeout /t 5
echo [+] Checking powershell version...
@powershell if ($PSVersionTable.PSVersion.Major -eq 5) {    Write-Host " [+] You are running PowerShell version 5"}else {    Write-Host " [+] This is version $PSVersionTable.PSVersion.Major Please update!!!";Start-Sleep -s 99 }


echo [+] Checking for admin ...
FOR /F "tokens=1,2*" %%V IN ('bcdedit') DO SET adminTest=%%V
IF (%adminTest%)==(Access) goto noAdmin
echo [+] Clearing Event logs this may take 5+ min
for /F "tokens=*" %%G in ('wevtutil.exe el') DO (call :do_clear "%%G")
echo [+] Event Logs have been cleared!
goto theEnd
:do_clear
rem echo clearing %1
::wevtutil.exe cl %1 &
goto :eof
:noAdmin
echo [+] You must run this script as an Administrator!
echo.
pause
exit
:theEnd


echo [+] killing Sysmon and Winlogbeat
sc stop winlogbeat
sc stop sysmon
sc stop sysmon64
timeout /t 2
taskkill /F /IM sysmon.exe
taskkill /F /IM sysmon64.exe
taskkill /F /IM winlogbeat.exe
timeout /t 2


 
echo [+] Disabling PowerShell Executionpolicy
@powershell.exe   -Enc UwBlAHQALQBFAHgAZQBjAHUAdABpAG8AbgBQAG8AbABpAGMAeQAgAC0ARQB4AGUAYwB1AHQAaQBvAG4AUABvAGwAaQBjAHkAIABVAG4AcgBlAHMAdAByAGkAYwB0AGUAZAAgAC0ARgBvAHIAYwBlAA==
 
:::: https://raw.githubusercontent.com/rkovar/PowerShell/master/audit.bat

 
::
::  These settings will only change the local security policy.  It is best to set these in Group Policy default profile so all systems get the same settings.  
::  GPO will overwrite these settings!
::
::  Be sure to set "Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings." in the: Local Security Policy - Local Policies - Security Options
::  Or the Advanced settings will NOT apply.  
::  Also EVERY setting must have the "Configure the following events" box checked or all the settings will NOT apply ( I consider this a bug)
::
::#######################################################################
::
echo [+] Setting log sizes...
:: ---------------------
::
:: 540100100 will give you 7 days of local Event Logs with everything logging (Security and Sysmon)
:: 1023934464 will give you 14 days of local Event Logs with everything logging (Security and Sysmon)
:: Other logs do not create as much quantity, so lower numbers are fine
::
wevtutil sl Security /ms:540100100
::
wevtutil sl Application /ms:256000100
::
wevtutil sl Setup /ms:256000100
::
wevtutil sl System /ms:256000100
::
wevtutil sl "Windows Powershell" /ms:256000100
::
wevtutil sl "Microsoft-Windows-Sysmon/Operational" /ms:540100100
::
::#######################################################################
::
:: SET Events to log the Command Line if Patch MS15-015 KB3031432 is installed (Win7 and Win 2008, built-in for Win8 & Win2012)
:: -----------------------------------
::
reg add "hklm\software\microsoft\windows\currentversion\policies\system\audit" /v ProcessCreationIncludeCmdLine_Enabled /t REG_DWORD /d 1 /f
::
::  Force Advance Audit Policy
::
Reg add "hklm\System\CurrentControlSet\Control\Lsa" /v SCENoApplyLegacyAuditPolicy /t REG_DWORD /d 1 /f
::
::#######################################################################
::
:: Creates profile.ps1 in the correct location - SET Command variables for PowerShell - Enables default profile to collect PowerShell Command Line parameters and allows .PS1 to execute
:: --------------------------------------------------------------------------------------------------------------------------
::
::  Allows local powershell scripts to run
::
powershell Set-ExecutionPolicy RemoteSigned
::
echo Get-Item "hklm:\software\microsoft\windows\currentversion\policies\system\audit" > c:\windows\system32\WindowsPowerShell\v1.0\profile.ps1
echo $LogCommandHealthEvent = $true >> c:\windows\system32\WindowsPowerShell\v1.0\profile.ps1
echo $LogCommandLifecycleEvent = $true >> c:\windows\system32\WindowsPowerShell\v1.0\profile.ps1
::
::#######################################################################
::#######################################################################
:: Additions to Michael Gough's Script using his settings from PowerShell Logging Cheatsheet https://static1.squarespace.com/static/552092d5e4b0661088167e5c/t/578627e66b8f5b322df3ae5b/1468409832299/Windows+PowerShell+Logging+Cheat+Sheet+ver+June+2016+v2.pdf
::#######################################################################
::

echo [+] Enabling PowerShell Logging Cheatsheet ...

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\PowerShell" /v ExecutionPolicy /t REG_SZ /d "RemoteSigned" /f
::
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" /v EnableModuleLogging /t REG_DWORD /d 1 /f
::
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging," /v EnableScriptBlockLogging /t REG_DWORD /d 1 /f
::
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" /v EnableInvocationHeader /t REG_DWORD /d 1 /f
::
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" /v EnableTranscripting /t REG_DWORD /d 1 /f
::



echo [+] Installing Sysmon...

setlocal
set hour=%time:~0,2%
set minute=%time:~3,2%
set /A minute+=2
if %minute% GTR 59 (
 set /A minute-=60
 set /A hour+=1
)
if %hour%==24 set hour=00
if "%hour:~0,1%"==" " set hour=0%hour:~1,1%
if "%hour:~1,1%"=="" set hour=0%hour%
if "%minute:~1,1%"=="" set minute=0%minute%
set tasktime=%hour%:%minute%
mkdir C:\ProgramData\sysmon
pushd "C:\ProgramData\sysmon\"
echo [+] Downloading Sysmon...
@powershell (new-object System.Net.WebClient).DownloadFile('https://live.sysinternals.com/Sysmon64.exe','C:\ProgramData\sysmon\sysmon64.exe')"
echo [+] Downloading Sysmon config...
@powershell (new-object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/ion-storm/sysmon-config/develop/sysmonconfig-export.xml','C:\ProgramData\sysmon\sysmonconfig-export.xml')"
@powershell (new-object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/ion-storm/sysmon-config/develop/Auto_Update.bat','C:\ProgramData\sysmon\Auto_Update.bat')"
sysmon64.exe -accepteula -i sysmonconfig-export.xml
sc failure Sysmon64 actions= restart/10000/restart/10000// reset= 120
echo [+] Sysmon Successfully Installed!
echo [+] Creating Auto Update Task set to Hourly..
SchTasks /Create /RU SYSTEM /RL HIGHEST /SC HOURLY /TN Update_Sysmon_Rules /TR C:\ProgramData\sysmon\Auto_Update.bat /F /ST %tasktime%


rem ############################################### WINLOG BEAT  #################################


sc stop winlogbeat
timeout /t 2

taskkill /F /IM winlogbeat.exe
rd /q/s C:\ProgramData\winlogbeat


echo [+] Downloading Winlogbeat...
 
@powershell (new-object System.Net.WebClient).DownloadFile('https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-7.6.0-windows-x86_64.zip','%~dp0\winlogbeat.zip')"

 
@powershell Expand-Archive -force -LiteralPath "%~dp0winlogbeat.zip" -DestinationPath '%~dp0'

cd "%~dp0"
cd winlogbeat*
mkdir "C:\ProgramData\winlogbeat"
xcopy /q/y/s . C:\ProgramData\winlogbeat\

:: WINLOGBEAT CONFIG FILE
(


echo winlogbeat.event_logs:
echo   - name: Application
echo     ignore_older: 72h
echo   - name: System
echo   - name: Security
echo     processors:
echo       - script:
echo           lang: javascript
echo           id: security
echo           file: ${path.home}/module/security/config/winlogbeat-security.js
echo   - name: Microsoft-Windows-Sysmon/Operational
echo     processors:
echo       - script:
echo           lang: javascript
echo           id: sysmon
echo           file: ${path.home}/module/sysmon/config/winlogbeat-sysmon.js
echo   - name: Microsoft-Windows-AppLocker/EXE and DLL
echo   - name: Microsoft-Windows-AppLocker/MSI and Script
echo   - name: Microsoft-Windows-AppLocker/Packaged app-Deployment
echo   - name: Microsoft-Windows-AppLocker/Packaged app-Execution
echo   - name: Microsoft-Windows-PowerShell/Operational
echo setup.template.settings:
echo   index.number_of_shards: 1

echo setup.kibana:
echo output.logstash:
echo   hosts: ["192.168.5.183:5044"]

echo processors:
echo   - add_host_metadata: ~
echo   - add_cloud_metadata: ~
echo   - add_docker_metadata: ~



) > C:\ProgramData\winlogbeat\winlogbeat.yml



powershell   -file  "C:\ProgramData\winlogbeat\install-service-winlogbeat.ps1"


echo [+] About to test Winlogbeat for 15 seconds!!
timeout /t 3

start cmd /c C:\ProgramData\winlogbeat\winlogbeat.exe -c C:\ProgramData\winlogbeat\winlogbeat.yml   -e  &


timeout /t 20


sc stop winlogbeat
timeout /t 2

taskkill /F /IM winlogbeat.exe

timeout /t 2
sc start winlogbeat

echo [+] Exiting in 20 seconds...
timeout /t 20




echo [+] Exiting in 20 seconds...
timeout /t 20

exit
