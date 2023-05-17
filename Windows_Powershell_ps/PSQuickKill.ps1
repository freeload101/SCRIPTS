Set-Variable -Name ErrorActionPreference -Value SilentlyContinue

#Get-Process | Where{!($_.UserName -match "NT AUTHORITY\\(?:SYSTEM|(?:LOCAL|NETWORK) SERVICE)") -and !($_.ProcessName -eq "explorer") -and !($_.ProcessName -eq "powershell")} 

#Set-Variable -Name ErrorActionPreference -Value SilentlyContinue
# Get-Process | Where{!($_.UserName -match "NT AUTHORITY\\(?:SYSTEM|(?:LOCAL|NETWORK) SERVICE)") -and !($_.ProcessName -eq "explorer") -and !($_.ProcessName -eq "powershell")}|Stop-Process  -Force




$count = (Get-Process | Where{!($_.UserName -match "NT AUTHORITY\\(?:SYSTEM|(?:LOCAL|NETWORK) SERVICE)") -and !($_.ProcessName -eq "explorer") -and !($_.ProcessName -eq "powershell")}).Count
write-host "$count` Processes to be killed `n"

#(Get-Process | Where{!($_.UserName -match "NT AUTHORITY\\(?:SYSTEM|(?:LOCAL|NETWORK) SERVICE)") -and !($_.ProcessName -eq "explorer") -and !($_.ProcessName -eq "powershell")}).ProcessName
Get-Process | Where{!($_.UserName -match "NT AUTHORITY\\(?:SYSTEM|(?:LOCAL|NETWORK) SERVICE)") -and !($_.ProcessName -eq "explorer") -and !($_.ProcessName -eq "powershell")}|Stop-Process  -Force


$count = (Get-Process | Where{!($_.UserName -match "NT AUTHORITY\\(?:SYSTEM|(?:LOCAL|NETWORK) SERVICE)") -and !($_.ProcessName -eq "explorer") -and !($_.ProcessName -eq "powershell")}).Count
write-host "$count` Processes Active `n"


write-host "`DONE`n"
Start-Sleep -Seconds 10
