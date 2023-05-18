Set-Variable -Name ErrorActionPreference -Value SilentlyContinue

$count = (Get-Process | Where{!($_.UserName -match "NT AUTHORITY\\(?:SYSTEM|(?:LOCAL|NETWORK) SERVICE)") -and !($_.ProcessName -eq "explorer") -and !($_.ProcessName -eq "powershell")}).Count
write-host "$count` Processes to be killed `n"

Get-Process | Where{!($_.UserName -match "NT AUTHORITY\\(?:SYSTEM|(?:LOCAL|NETWORK) SERVICE)") -and !($_.ProcessName -eq "powershell" -and !($_.ProcessName -eq "explorer") -and !($_.ProcessName -eq "powershell_ise") -and !($_.ProcessName -eq "wdm") -and !($_.ProcessName -eq "conhost")  )}  | Sort-Object | Get-Unique | foreach { 
write-host "About to kill " $_ 
Start-Sleep -Seconds .5
Stop-Process  $_ -Force 
 

} 
  

$count = (Get-Process | Where{!($_.UserName -match "NT AUTHORITY\\(?:SYSTEM|(?:LOCAL|NETWORK) SERVICE)") -and !($_.ProcessName -eq "explorer") -and !($_.ProcessName -eq "powershell")}).Count
write-host "$count` Processes Active `n"

write-host "`DONE`n"
Start-Sleep -Seconds 10
