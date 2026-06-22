# ==========================================
# CONFIGURATION VARIABLES
# ==========================================
$TargetIP = "192.168.1.151" #  SSH tunnel target 

# ==========================================
# SCRIPT EXECUTION
# ==========================================

# 1. Dynamically grab the active Default Gateway IPv4 address before connecting to VPN
$defaultGateway = (Get-NetRoute -DestinationPrefix '0.0.0.0/0' | 
                   Sort-Object Metric | 
                   Select-Object -First 1).NextHop

if (-not $defaultGateway) {
    Write-Error "Could not automatically detect an active default gateway. Aborting script."
    exit
}
Write-Host "Found active local gateway: $defaultGateway" -ForegroundColor Green

# 2. Append mapping to the Windows hosts file safely
$hostsPath = "C:\Windows\System32\drivers\etc\hosts"
$hostsEntry = "3.5.28.216 com-stratasan-health-uploads.s3.amazonaws.com"

if ((Get-Content $hostsPath) -notcontains $hostsEntry) {
    Add-Content -Path $hostsPath -Value "`n$hostsEntry"
    Write-Host "Added S3 bucket entry to hosts file." -ForegroundColor Cyan
}

# 3. Configure and start the IP Helper service for portproxy functionality
Set-Service -Name iphlpsvc -StartupType Automatic
Start-Service -Name iphlpsvc -ErrorAction SilentlyContinue

# 4. Flush out any stale portproxy entries
netsh interface portproxy reset

# 5. Launch OpenConnect in a BRAND NEW command prompt window
Write-Host "Launching OpenConnect VPN in a new window..." -ForegroundColor Yellow
Start-Process -FilePath "cmd.exe" -ArgumentList '/c ""C:\Program Files\OpenConnect\openconnect.exe" --protocol=anyconnect "https://vpn.stratadecision.com/SDTAbira""' -WindowStyle Normal

# 6. Wait completely for your confirmation before touching the network tables
Write-Host ""
Read-Host "--> LOG INTO THE VPN IN THE NEW WINDOW, THEN press [ENTER] here to apply network rules"

# 7. Apply network rules using the dynamically discovered local gateway IP
Write-Host "`nApplying local LAN bypass route and port proxy configurations..." -ForegroundColor Cyan

# Route internal LAN traffic back out to your local gateway 
route add 192.168.1.0 mask 255.255.255.0 $defaultGateway metric 1

# Bind portproxy listener to the local gateway interface using your variable target
netsh interface portproxy add v4tov4 listenport=2222 listenaddress=$defaultGateway connectport=22 connectaddress=$TargetIP

# 8. Print active port proxies to verify setup
Write-Host "`nActive Portproxy Rules:" -ForegroundColor Green
netsh interface portproxy show all
