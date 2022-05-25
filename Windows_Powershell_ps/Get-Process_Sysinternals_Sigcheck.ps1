(New-Object Net.WebClient).DownloadFile('https://download.sysinternals.com/files/Sigcheck.zip', 'Sigcheck.zip')
Expand-Archive .\Sigcheck.zip -DestinationPath .\ -Force
reg add "HKCU\Software\Sysinternals\SigCheck\VirusTotal" /v "VirusTotalTermsAccepted" /t REG_DWORD /d 1 /f
(Get-Process).Path| sort -Unique|ForEach-Object { sigcheck64 -vt -nobanner -accepteula -c "$_" | Select-String -Pattern 'Signed|VT link' -NotMatch }
