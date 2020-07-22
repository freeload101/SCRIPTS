@echo off

cd "%~dp0"
 
 
echo [+] Checking for admin ...
FOR /F "tokens=1,2*" %%V IN ('bcdedit') DO SET adminTest=%%V
IF (%adminTest%)==(Access) goto noAdmin
goto theEnd

:noAdmin
echo [+] You must run this script as an Administrator!
echo.
pause
exit

:theEnd


rem ######################## CLEANUP

echo [+] trying to remove CS

REM this is broken 'Attempt to uninstall valid only when bundle is installed'
WindowsSensor.exe /repair /uninstall /quiet
ping 123.123.123.123 -n 5 -w 1 > %temp%\null

rem this also may be broken..
MsiExec.exe   /quiet /qn /norestart  /x{6096FFC9-2662-4914-AC38-8F85CF4A13CF} 
ping 123.123.123.123 -n 5 -w 1 > %temp%\null
 


CsUninstallTool.exe  /quiet
ping 123.123.123.123 -n 5 -w 1 > %temp%\null



echo [+] Removing CS Logs
del "%LOCALAPPDATA%\Temp\CrowdStrike*.???"
del "%SYSTEMROOT%\Temp\CrowdStrike*.???"

if exist "%LOCALAPPDATA%\Temp\CrowdStrike*.???" (
	echo [+] Can't remove logs it's likly CS is still running and was unable to uninstall
	echo [+] exiting
	pause
	exit
)

if exist "%SYSTEMROOT%\Temp\CrowdStrike*.???" (
	echo [+] Can't remove logs it's likly CS is still running and was unable to uninstall
	echo [+] exiting
	pause
	exit
)



REM ############################### DIAG INFO



echo [+] Getting External IP: 
echo [+] Getting External IP: > CS_DIAG_OUT.txt
powershell -command "Invoke-RestMethod http://ipinfo.io/json | Select -exp ip" >> CS_DIAG_OUT.txt 

echo [+] Getting Internal IPs:
echo [+] Getting Internal IPs: >> CS_DIAG_OUT.txt
powershell -command "Get-NetIPAddress  | select IPAddress" >> CS_DIAG_OUT.txt


echo [+] Getting Firewall Status:
echo [+] Getting Firewall Status >> CS_DIAG_OUT.txt
netsh advfirewall show allprofiles state >> CS_DIAG_OUT.txt

echo [+] Exporting Firewall Rules for review
powershell -command "get-netfirewallrule | Get-NetFirewallPortFilter | select-object Protocol, LocalPort, RemotePort, InstanceID, CreationClassName | export-csv ""$Env:%~dp0\firewall.txt""" &


echo [+] Testing Connectivity 
echo [+] Testing Connectivity >> CS_DIAG_OUT.txt

echo [+] Chcecking assets-public.falcon.crowdstrike.com  >> CS_DIAG_OUT.txt
powershell -command "Invoke-WebRequest -UseBasicParsing -Uri https://assets-public.falcon.crowdstrike.com  " >> CS_DIAG_OUT.txt
echo [+] Chcecking ts01-b.cloudsink.net  >> CS_DIAG_OUT.txt
powershell -command "Invoke-WebRequest -UseBasicParsing -Uri https://ts01-b.cloudsink.net " >> CS_DIAG_OUT.txt
echo [+] Chcecking lfodown01-b.cloudsink.net  >> CS_DIAG_OUT.txt
powershell -command "Invoke-WebRequest -UseBasicParsing -Uri https://lfodown01-b.cloudsink.net " >> CS_DIAG_OUT.txt
echo [+] Chcecking falcon.crowdstrike.com  >> CS_DIAG_OUT.txt
powershell -command "Invoke-WebRequest -UseBasicParsing -Uri  https://falcon.crowdstrike.com " >> CS_DIAG_OUT.txt
echo [+] Chcecking assets.falcon.crowdstrike.com   >> CS_DIAG_OUT.txt
powershell -command "Invoke-WebRequest -UseBasicParsing -Uri  https://assets.falcon.crowdstrike.com " >> CS_DIAG_OUT.txt
echo [+] Chcecking assets-public.falcon.crowdstrike.com  >> CS_DIAG_OUT.txt
powershell -command "Invoke-WebRequest -UseBasicParsing -Uri  https://assets-public.falcon.crowdstrike.com " >> CS_DIAG_OUT.txt


echo [+] Running Packet Capture  "%temp%\capture.etl"
#netsh trace start capture=yes tracefile="%temp%\capture.etl" maxsize=512 filemode=circular overwrite=yes report=no correlation=no IPv4.SourceAddress=(192.168.0.2) IPv4.DestinationAddress=(192.168.0.1) Ethernet.Type=IPv4
netsh trace start capture=yes tracefile="%temp%\capture.etl" maxsize=512 filemode=circular overwrite=yes report=no correlation=no Ethernet.Type=IPv4
  


REM ####################### REINSTALL 
echo [+] Installing... This may take upto 15 minutes! CS has to checkin to cloud to complete install
WindowsSensor.exe /install /quiet /norestart CID=XXXXXXXXXXXXXXXXXXXXXXXXXXXXX-D7 
ping 123.123.123.123 -n 1 -w 1 > %temp%\null

 
echo [+] Checking service status 
sc query csagent 

echo [+] Checking service status: >> CS_DIAG_OUT.txt
sc query csagent >> CS_DIAG_OUT.txt





echo [+] sending sample alert with choice /m crowdstrike_sample_detection
echo [+] sending sample alert with choice /m crowdstrike_sample_detection >> CS_DIAG_OUT.txt
choice  /T 1 /D y /m crowdstrike_sample_detection  >> CS_DIAG_OUT.txt
choice  /T 1 /D y /m crowdstrike_sample_detection  


echo [+] Performing test alerts PowerSploit

powershell.exe -exec Bypass -C "IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/dev/Privesc/PowerUp.ps1');Invoke-AllChecks"




goto EOF1

:error1
echo [+] General Error!
pause
exit

:EOF1
echo All done

echo [+] Stopping/Opening Packet Capture  "%temp%\capture.etl"
netsh trace stop
echo [+] Downloading https://github.com/microsoft/etl2pcapng/releases/download/v1.3.0/etl2pcapng.zip 
powershell "(New-Object Net.WebClient).DownloadFile('https://github.com/microsoft/etl2pcapng/releases/download/v1.3.0/etl2pcapng.zip', '%temp%\etl2pcapng.zip')"
powershell "Expand-Archive '%temp%\etl2pcapng.zip' -DestinationPath '%temp%\' -Force"
"%temp%\etl2pcapng\x86\etl2pcapng.exe" "%temp%\capture.etl" "%temp%\capture.etl.pcap"

notepad  "%temp%\capture.etl.pcap"
  

for /f "delims=" %%i IN ('dir/s/b %LOCALAPPDATA%\Temp\CrowdStrike*') do (
echo [+] "%%i"  >> CS_DIAG_OUT.txt
type "%%i" >> CS_DIAG_OUT.txt
)

for /f "delims=" %%i IN ('dir/s/b %SYSTEMROOT%\Temp\CrowdStrike*') do (
echo [+] "%%i"  >> CS_DIAG_OUT.txt
type  "%%i" >> CS_DIAG_OUT.txt
)

ping 123.123.123.123 -n 1 -w 1 > %temp%\null

notepad "%~dp0\CS_DIAG_OUT.txt" &
notepad "%~dp0\firewall.txt" &




pause
exit

