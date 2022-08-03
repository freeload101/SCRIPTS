$downloadUri = ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/trustcrypto/OnlyKey-App/releases/latest").assets | Where-Object name -like *.exe ).browser_download_url
Invoke-WebRequest -Uri $downloadUri -Out $env:LOCALAPPDATA\Onlykey.exe
$Env:__COMPAT_LAYER='RunAsInvoker'
Start-Process -FilePath "$env:LOCALAPPDATA\Onlykey.exe" -ArgumentList  " /D=$env:LOCALAPPDATA\Onlykey\  "  #-Wait  -Verbose -WindowStyle Hidden 

start-sleep -Seconds 2
$SendWait = New-Object -ComObject wscript.shell;
$SendWait.SendKeys('{ENTER}')

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

Wait-Process -Name Onlykey -Timeout 300

explorer "$env:LOCALAPPDATA\Onlykey\"

Start-Process -FilePath "$env:LOCALAPPDATA\Onlykey\nw.exe"
