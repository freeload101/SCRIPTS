$ngrokApiToken = "3CPSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXdKbrvGfc"
$ngrokauthtoken = "3CM7pXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXFE4"


# Must be run as Administrator
$batContent = @"
@echo off
set __COMPAT_LAYER=RUNASINVOKER
"C:\Program Files (x86)\Sage\Peachtree\Peachw.exe"
"@

$excludedProfiles = @('Default', 'Default User', 'Public', 'All Users')

# Map HKU hive
if (!(Get-PSDrive -Name HKU -ErrorAction SilentlyContinue)) {
    New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | Out-Null
}

$userProfiles = Get-ChildItem -Path "C:\Users" -Directory |
    Where-Object { $_.Name -notin $excludedProfiles }

foreach ($profile in $userProfiles) {
    $desktopPath = $null
    $hiveMounted = $false
    $hiveKey = "TempHive_$($profile.Name)"

    # Try to resolve SID
    $sid = $null
    try {
        $sid = (New-Object System.Security.Principal.NTAccount($profile.Name)).Translate(
            [System.Security.Principal.SecurityIdentifier]).Value
    } catch { }

    # Determine registry path to use
    $regPath = $null
    if ($sid -and (Test-Path "HKU:\$sid")) {
        $regPath = "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
    } else {
        $hivePath = Join-Path $profile.FullName "NTUSER.DAT"
        if (Test-Path $hivePath) {
            reg load "HKU\$hiveKey" $hivePath 2>&1 | Out-Null
            $hiveMounted = $true
            $regPath = "Registry::HKU\$hiveKey\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
        }
    }

    # Read Desktop value from registry
    if ($regPath) {
        $rawDesktop = (Get-ItemProperty -Path $regPath -Name Desktop -ErrorAction SilentlyContinue).Desktop

        if ($rawDesktop) {
            # Replace common per-user variables manually
            $expanded = $rawDesktop `
                -replace [regex]::Escape('%USERPROFILE%'), $profile.FullName `
                -replace [regex]::Escape('%OneDriveCommercial%'), '' `
                -replace [regex]::Escape('%OneDrive%'), ''

            # If OneDrive variable was stripped, find the actual OneDrive folder
            if ($rawDesktop -match '%OneDrive') {
                # Grab the subfolder after the variable (usually \Desktop)
                $subFolder = ($rawDesktop -replace '.*%OneDrive[^%]*%', '').TrimStart('\')

                # Find OneDrive folder in the user's profile (handles any tenant name)
                $oneDriveFolder = Get-ChildItem -Path $profile.FullName -Directory -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -like "OneDrive*" } |
                    Select-Object -First 1

                if ($oneDriveFolder) {
                    $desktopPath = Join-Path $oneDriveFolder.FullName $subFolder
                }
            } else {
                $desktopPath = [System.Environment]::ExpandEnvironmentVariables($expanded)
            }
        }
    }

    # Unload hive if we mounted it
    if ($hiveMounted) {
        [gc]::Collect()
        [gc]::WaitForPendingFinalizers()
        reg unload "HKU\$hiveKey" 2>&1 | Out-Null
    }

    # Fallback: check for OneDrive* folder with Desktop inside
    if (!$desktopPath -or !(Test-Path $desktopPath)) {
        $oneDriveFolder = Get-ChildItem -Path $profile.FullName -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like "OneDrive*" } |
            Select-Object -First 1

        if ($oneDriveFolder) {
            $candidate = Join-Path $oneDriveFolder.FullName "Desktop"
            if (Test-Path $candidate) {
                $desktopPath = $candidate
            }
        }
    }

    # Final fallback: standard Desktop
    if (!$desktopPath -or !(Test-Path $desktopPath)) {
        $desktopPath = Join-Path $profile.FullName "Desktop"
    }

    # Write the bat file
    if (Test-Path $desktopPath) {
        $batFile = Join-Path $desktopPath "SAGE 50 NOADMIN.bat"
        Set-Content -Path $batFile -Value $batContent -Encoding ASCII
        Write-Host "Created: $batFile"
    } else {
        Write-Warning "No valid Desktop found for: $($profile.Name)"
    }
}



# ── ADD ALL LOCAL USERS TO REMOTE DESKTOP USERS GROUP ────────────────────────

# Add the current logged-in user explicitly
$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$currentUserShort = $currentUser.Split('\')[-1]

Add-LocalGroupMember -Group "Remote Desktop Users" -Member $currentUserShort -ErrorAction SilentlyContinue
Write-Host "[+] Added current user: $currentUserShort" -ForegroundColor Green

# Add ALL local user accounts to Remote Desktop Users
$localUsers = Get-LocalUser | Where-Object { $_.Enabled -eq $true }

foreach ($user in $localUsers) {
    try {
        Add-LocalGroupMember -Group "Remote Desktop Users" -Member $user.Name -ErrorAction Stop
        Write-Host "[+] Added: $($user.Name)" -ForegroundColor Green
    } catch {
        Write-Host "[!] Skipped (already member or built-in): $($user.Name)" -ForegroundColor Yellow
    }
}

# Also ensure Administrators group has RDP access (sometimes stripped by GPO)
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "Administrators" -ErrorAction SilentlyContinue

# Confirm RDP is enabled
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' `
    -Name "fDenyTSConnections" -Value 0

# Disable NLA so any account can connect without Kerberos/credential issues
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' `
    -Name "UserAuthentication" -Value 0

# Re-enable firewall rules
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Verify group membership
Write-Host "`n[*] Current Remote Desktop Users group members:" -ForegroundColor Cyan
Get-LocalGroupMember -Group "Remote Desktop Users" | Format-Table Name, ObjectClass -AutoSize


# ── RDP SERVICE & CERTIFICATE FIX ────────────────────────────────────────────

# Force restart the RDP service
Write-Host "[*] Restarting RDP service..." -ForegroundColor Cyan
Restart-Service -Name "TermService" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

# Delete corrupt/expired RDP self-signed certificate and let it regenerate
Write-Host "[*] Clearing RDP certificates..." -ForegroundColor Cyan
Get-ChildItem -Path "Cert:\LocalMachine\Remote Desktop\" | Remove-Item -Force -ErrorAction SilentlyContinue

# Restart RDP service again so it regenerates the cert
Restart-Service -Name "TermService" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

# Disable NLA (fixes cross-machine auth mismatch)
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' `
    -Name "UserAuthentication" -Value 0

# Ensure RDP port is correct (sometimes gets changed)
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' `
    -Name "PortNumber" -Value 3389

# Confirm RDP is enabled
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' `
    -Name "fDenyTSConnections" -Value 0

# Restart Windows Firewall service to flush rule state
Restart-Service -Name "mpssvc" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Re-enable all RDP firewall rules
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Verify RDP is listening on 3389
Write-Host "`n[*] Checking if RDP is listening on port 3389..." -ForegroundColor Cyan
$listening = netstat -ano | findstr ":3389"
if ($listening) {
    Write-Host " [+] RDP is listening:" -ForegroundColor Green
    Write-Host $listening
} else {
    Write-Host " [!] RDP is NOT listening on 3389 - check TermService" -ForegroundColor Red
}

# Show RDP service status
$svc = Get-Service -Name "TermService"
Write-Host "`n[*] TermService status: $($svc.Status)" -ForegroundColor Cyan
# ─────────────────────────────────────────────────────────────────────────────



# ── STOP ALL EXISTING NGROK TUNNEL SESSIONS VIA API ──────────────────────────

$headers = @{
    Authorization  = "Bearer $ngrokApiToken"
    "Ngrok-Version" = "2"
}

Write-Host "`n[*] Fetching active ngrok tunnel sessions..." -ForegroundColor Cyan

try {
    $sessions = Invoke-RestMethod -Uri "https://api.ngrok.com/tunnel_sessions" `
        -Headers $headers -Method Get

    if ($sessions.tunnel_sessions.Count -gt 0) {
        foreach ($session in $sessions.tunnel_sessions) {
            $sessionId = $session.id
            Write-Host " [>] Stopping session: $sessionId" -ForegroundColor Yellow
            Invoke-RestMethod -Uri "https://api.ngrok.com/tunnel_sessions/$sessionId/stop" `
                -Headers $headers -Method Post -Body "{}" -ContentType "application/json" `
                -ErrorAction SilentlyContinue
        }
        Write-Host " [+] All sessions stopped." -ForegroundColor Green
    } else {
        Write-Host " [!] No active sessions found." -ForegroundColor Gray
    }
} catch {
    Write-Host " [!] Failed to reach ngrok API: $_" -ForegroundColor Red
}

Start-Sleep -Seconds 3
# ─────────────────────────────────────────────────────────────────────────────

# Enable RDP via Registry
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0

# Enable built-in RDP firewall rule group
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Add explicit inbound firewall rule for RDP port 3389 (TCP)
New-NetFirewallRule -DisplayName "Allow RDP TCP 3389" `
    -Direction Inbound -Protocol TCP -LocalPort 3389 `
    -Action Allow -Profile Any -Enabled True -ErrorAction SilentlyContinue

# Add explicit inbound firewall rule for RDP port 3389 (UDP)
New-NetFirewallRule -DisplayName "Allow RDP UDP 3389" `
    -Direction Inbound -Protocol UDP -LocalPort 3389 `
    -Action Allow -Profile Any -Enabled True -ErrorAction SilentlyContinue

# NLA
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' `
    -Name "UserAuthentication" -Value 1

# Kill existing local ngrok process
Get-Process -Name ngrok -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2

# Cleanup
Remove-Item -Path ".\ngrok.log" -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".\ngrok.zip" -Force -ErrorAction SilentlyContinue

# Download and extract ngrok
Invoke-WebRequest -Uri "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip" -OutFile "ngrok.zip"
Expand-Archive -Path "ngrok.zip" -DestinationPath "." -Force

# Configure auth token
$cfg = Start-Process -FilePath ".\ngrok.exe" `
    -ArgumentList "config add-authtoken $ngrokauthtoken" `
    -WindowStyle Hidden -PassThru
$cfg.WaitForExit()

# Start ngrok tunnel
Start-Process -FilePath ".\ngrok.exe" -ArgumentList "tcp 3389 --log=ngrok.log" -WindowStyle Hidden

# Wait and poll log until tunnel URL appears
Write-Host "`n[*] Waiting for ngrok tunnel to establish..." -ForegroundColor Cyan
$tunnelUrl = $null
$timeout = 30
$elapsed = 0

while ($elapsed -lt $timeout) {
    Start-Sleep -Seconds 2
    $elapsed += 2

    if (Test-Path ".\ngrok.log") {
        $logContent = Get-Content ".\ngrok.log" -Raw
        if ($logContent -match 'url=(tcp://[^\s]+)') {
            $tunnelUrl = $matches[1]
            break
        }
    }
}

if ($tunnelUrl) {
    $parts = $tunnelUrl -replace "tcp://", "" -split ":"
    $rdpHost = $parts[0]
    $rdpPort = $parts[1]

    Write-Host "`n============================================" -ForegroundColor Green
    Write-Host " RDP TUNNEL ACTIVE" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Green
    Write-Host " Address : $rdpHost" -ForegroundColor Yellow
    Write-Host " Port    : $rdpPort" -ForegroundColor Yellow
    Write-Host " Full URL: $tunnelUrl" -ForegroundColor Yellow
    Write-Host "============================================" -ForegroundColor Green
    Write-Host "`n[*] Connect via RDP using:" -ForegroundColor Cyan
    Write-Host "    mstsc /v:${rdpHost}:${rdpPort}" -ForegroundColor White
} else {
    Write-Host "`n[!] Tunnel URL not found within $timeout seconds. Check ngrok.log." -ForegroundColor Red
    Get-Content ".\ngrok.log"
}
