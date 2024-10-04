# This script aids in troubleshooting Windows system issues by implementing a white list of required processes and closing unnecessary ones, reducing CPU usage. For advanced assistance, consult the following resources:

# https://github.com/freeload101/CrowdStrike_RTR_Powershell_Scripts/blob/main/srum_dump2.ps1
# https://github.com/freeload101/SCRIPTS/blob/master/Windows_Powershell_ps/WPS_WPR_Windows%20Performance%20Analyzer.ps1
# https://github.com/freeload101/CrowdStrike_RTR_Powershell_Scripts

# safe mode add/remove software 
# REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Minimal\MSIServer" /VE /T REG_SZ /F /D "Service"
# REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Network\MSIServer" /VE /T REG_SZ /F /D "Service"
# net start msiserver


Set-Variable -Name ErrorActionPreference -Value SilentlyContinue

$countb4 = (Get-Process).Count
 
 
Get-Process   | Where{!($_.UserName -match "NT AUTHORITY\\(?:SYSTEM|(?:LOCAL|NETWORK) SERVICE)") -and !($_.ProcessName -eq "explorer") -and !($_.ProcessName -eq "smss")  -and !($_.ProcessName -eq "conhost")  -and !($_.ProcessName -eq "powershell") -and !($_.ProcessName -eq "smartscreen") -and !($_.ProcessName -eq "sihost")  -and !($_.ProcessName -eq "CSFalconService") -and !($_.ProcessName -eq "CSFalconContainer") -and !($_.ProcessName -eq "SecurityHealthService") -and !($_.ProcessName -eq "SecurityHealthSystray") -and !($_.ProcessName -eq "cmd.exe") -and !($_.ProcessName -eq "explorer") -and !($_.ProcessName -eq "taskmgr") -and !($_.ProcessName -eq "svchost") -and !($_.ProcessName -eq "lsass") -and !($_.ProcessName -eq "dwm") -and !($_.ProcessName -eq "fontdrvhost") -and !($_.ProcessName -eq "ctfmon") -and !($_.ProcessName -eq "tasklist") -and !($_.ProcessName -eq "Winlogon") -and !($_.ProcessName -eq "dllhost") -and !($_.ProcessName -eq "lsaiso") -and !($_.ProcessName -eq "pwsh") -and !($_.ProcessName -eq "powershell_ise")  } | select -Unique | foreach { 
write-host "About to kill: " $_.ProcessName
# DEBUG Start-Sleep -Seconds 10
Stop-Process  $_.Id -Force 
}
 

$countafter = (Get-Process).Count
$countkilled = $countb4-$countafter
write-host "Killed $countkilled Processes"

write-host "`DONE`n"
Start-Sleep -Seconds 10
