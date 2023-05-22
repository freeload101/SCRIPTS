Set-Variable -Name ErrorActionPreference -Value SilentlyContinue

$countb4 = (Get-Process).Count
 
 
Get-Process   | Where{!($_.UserName -match "NT AUTHORITY\\(?:SYSTEM|(?:LOCAL|NETWORK) SERVICE)") -and !($_.ProcessName -eq "explorer") -and !($_.ProcessName -eq "smss")  -and !($_.ProcessName -eq "conhost")  -and !($_.ProcessName -eq "powershell") -and !($_.ProcessName -eq "smartscreen") -and !($_.ProcessName -eq "sihost")  -and !($_.ProcessName -eq "CSFalconService") -and !($_.ProcessName -eq "CSFalconContainer") -and !($_.ProcessName -eq "SecurityHealthService") -and !($_.ProcessName -eq "SecurityHealthSystray") -and !($_.ProcessName -eq "cmd.exe") -and !($_.ProcessName -eq "explorer") -and !($_.ProcessName -eq "taskmgr") -and !($_.ProcessName -eq "svchost") -and !($_.ProcessName -eq "lsass") -and !($_.ProcessName -eq "dwm") -and !($_.ProcessName -eq "fontdrvhost") -and !($_.ProcessName -eq "ctfmon") -and !($_.ProcessName -eq "tasklist") -and !($_.ProcessName -eq "dllhost") -and !($_.ProcessName -eq "lsaiso") -and !($_.ProcessName -eq "pwsh") -and !($_.ProcessName -eq "powershell_ise")  }  | foreach { 
write-host "Killing" $_.ProcessName
Start-Sleep -Seconds .5
Stop-Process  $_.Id -Force 
}
 

$countafter = (Get-Process).Count
$countkilled = $countb4-$countafter
write-host "Killed $countkilled Processes"

write-host "`DONE`n"
Start-Sleep -Seconds 10
