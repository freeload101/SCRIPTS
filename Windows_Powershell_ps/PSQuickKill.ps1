Set-Variable -Name ErrorActionPreference -Value SilentlyContinue

$countb4 = (Get-Process).Count
 
 
Get-Process   | Where{!($_.UserName -match "NT AUTHORITY\\(?:SYSTEM|(?:LOCAL|NETWORK) SERVICE)") -and !($_.ProcessName -eq "explorer") -and !($_.ProcessName -eq "smss")  -and !($_.ProcessName -eq "conhost")  -and !($_.ProcessName -eq "powershell") -and !($_.ProcessName -eq "smartscreen") -and !($_.ProcessName -eq "sihost") }  | foreach { 
write-host "Killing" $_.ProcessName
Start-Sleep -Seconds .5
Stop-Process  $_.Id -Force 
}
 

$countafter = (Get-Process).Count
write-host "$countafter killed out of  $countb4 Processes"

write-host "`DONE`n"
Start-Sleep -Seconds 10
