(New-Object Net.WebClient).DownloadFile('https://download.sysinternals.com/files/Sigcheck.zip', 'c:\windows\temp\Sigcheck.zip')
Expand-Archive c:\windows\temp\Sigcheck.zip -DestinationPath c:\windows\temp\ -Force
reg add "HKCU\Software\Sysinternals\SigCheck\VirusTotal" /v "VirusTotalTermsAccepted" /t REG_DWORD /d 1 /f

(Get-Process).Path| sort -Unique|ForEach-Object { Echo "Checking $_" ; c:\windows\temp\sigcheck64 -vt -nobanner -accepteula -c "$_" | Select-String -Pattern 'Signed|VT link' -NotMatch }
