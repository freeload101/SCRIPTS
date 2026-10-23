# PowerShell Debian NoAdmin - Pure PowerShell + portable 7-Zip
# UltraVNC deployed from the UltraVNC_1830.zip package (no installer, no admin).
$workDir = Get-Location
New-Item -ItemType Directory -Path $workDir -Force | Out-Null
Set-Location $workDir

$debianUrl   = "https://cloud.debian.org/images/archive/12.7.0/amd64/iso-cd/debian-12.7.0-amd64-netinst.iso"
$debianIso   = "$workDir\debian-12.7.0-amd64-netinst.iso"
$qemuUrl     = "https://qemu.weilnetz.de/w64/2021/qemu-w64-setup-20210208.exe"
$Memory      = "4096"

$env:PATH += ";$workDir\qemu"

function Download-File {
    param([string]$Url, [string]$File)
    $request = [System.Net.HttpWebRequest]::Create($Url)
    $request.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    $request.Referer   = "https://qemu.weilnetz.de/w64/"
    $request.Accept    = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
    $request.KeepAlive = $true
    $request.Headers.Add("Accept-Language", "en-US,en;q=0.5")
    $request.Headers.Add("Accept-Encoding", "gzip, deflate")
    $request.Headers.Add("DNT", "1")
    $request.Headers.Add("Upgrade-Insecure-Requests", "1")

    $response = $request.GetResponse()
    $responseStream = $response.GetResponseStream()
    $fileStream = [System.IO.FileStream]::new($File, 'Create')
    $responseStream.CopyTo($fileStream)
    $fileStream.Close()
    $responseStream.Close()
    $response.Close()
}

# Download Debian ISO
if (Test-Path $debianIso) {
    Write-Host "Debian ISO exists" -ForegroundColor Green
} else {
    Write-Host "Downloading Debian ISO..." -ForegroundColor Yellow
    Download-File $debianUrl $debianIso
}

# Download & install QEMU (silent, no admin)
if (Test-Path .\qemu\qemu-system-x86_64.exe) {
    Write-Host "QEMU Exists" -ForegroundColor Green
} else {
    Write-Host "Downloading QEMU" -ForegroundColor Yellow
    Download-File $qemuUrl "$workDir\qemu-w64-setup.exe"
    $env:__COMPAT_LAYER = "RUNASINVOKER"
    Start-Process -FilePath "$workDir\qemu-w64-setup.exe" -ArgumentList "/S", "/D=$workDir\qemu\" -Wait -NoNewWindow
}

function CheckAccel {
    # Auto-detect the best available accelerator; fall back to TCG.
    $Global:bestAccel = "tcg"
    if (Test-Path ".\qemu\qemu-system-x86_64w.exe") {
        $accelTest = & ".\qemu\qemu-system-x86_64w.exe" -accel help 2>&1
        if ($accelTest -match "whpx") { $Global:bestAccel = "whpx" }
        elseif ($accelTest -match "hax") { $Global:bestAccel = "hax" }
        elseif ($accelTest -match "hvf")  { $Global:bestAccel = "hvf" }
    }
    Write-Host "Using acceleration: $Global:bestAccel" -ForegroundColor Cyan
}

function Install-DebianVM {
    param(
        [string]$VMName = "debian-vm",
        [string]$VMSize = "200G",
        [int]$Memory = $Memory,
        [int]$CPUs = 1,
        [string]$ISOPath = $debianIso
    )

    New-Item -ItemType Directory -Path "$workDir\tftp" -Force | Out-Null

    # Preseed content
    $preseedContent = @"
### Localization and Language
d-i debian-installer/locale string en_US.UTF-8
d-i keyboard-configuration/xkb-keymap select us

### Network configuration
d-i netcfg/choose_interface select auto
d-i netcfg/disable_autoconfig boolean false
d-i netcfg/get_hostname string debian-vm
d-i netcfg/get_domain string local

### Mirror settings
d-i mirror/country string manual
d-i mirror/http/hostname string deb.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string

### Account setup
d-i passwd/root-login boolean true
d-i passwd/make-user boolean false
d-i passwd/root-password password root
d-i passwd/root-password-again password root

### Clock and time zone
d-i clock-setup/utc boolean true
d-i time/zone string UTC

### Partitioning
d-i partman-auto/method string regular
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

### Package selection
tasksel tasksel/first multiselect standard
d-i pkgsel/include string openssh-server qemu-guest-agent
d-i pkgsel/upgrade select full-upgrade

### Boot loader
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i finish-install/reboot_in_progress note

### Late commands
d-i preseed/late_command string \
    in-target sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config; \
    in-target systemctl enable ssh; \
    in-target systemctl restart ssh
"@

    $preseedContent | Out-File -FilePath "$workDir\tftp\preseed.cfg" -Encoding UTF8

    # === Acquire portable 7-Zip console (no admin). Debian 12 ISOs are zstd-compressed,
    # so we need a modern 7z.exe (7za alone cannot read zstd). Bootstrap chain:
    #   1. 7zr.exe  -> standalone reader of .7z format (bootstrap)
    #   2. extra.7z -> extracted with 7zr to obtain 7za.exe
    #   3. installer exe -> extracted with 7za.exe to obtain 7z.exe + 7z.dll
    Write-Host "Downloading portable 7-Zip console..." -ForegroundColor Yellow

    $sevenZipExe   = "$workDir\7z.exe"
    $sevenZipDll   = "$workDir\7z.dll"

    if (-not (Test-Path $sevenZipExe) -or -not (Test-Path $sevenZipDll)) {
        $sevenZipRUrl = "https://github.com/ip7z/7zip/releases/download/26.05/7zr.exe"
        $sevenZipR    = "$workDir\_7zr.exe"
        $sevenZipExtraUrl = "https://www.7-zip.org/a/7z2301-extra.7z"
        $sevenZipExtra  = "$workDir\_7zextra.7z"
        $sevenZipInstUrl = "https://www.7-zip.org/a/7z2301-x64.exe"
        $sevenZipInst   = "$workDir\_7zinst.exe"

        (New-Object System.Net.WebClient).DownloadFile($sevenZipRUrl, $sevenZipR)
        (New-Object System.Net.WebClient).DownloadFile($sevenZipExtraUrl, $sevenZipExtra)
        & $sevenZipR x $sevenZipExtra -o"$workDir\_7zextra" -y | Out-Null
        (New-Object System.Net.WebClient).DownloadFile($sevenZipInstUrl, $sevenZipInst)
        & "$workDir\_7zextra\7za.exe" x $sevenZipInst -o"$workDir\_7zsrc" -y | Out-Null
        Copy-Item "$workDir\_7zsrc\7z.exe" $sevenZipExe -Force
        Copy-Item "$workDir\_7zsrc\7z.dll" $sevenZipDll -Force
        Remove-Item $sevenZipInst -Force
        Remove-Item $sevenZipExtra -Force
        Remove-Item "$workDir\_7zextra" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item "$workDir\_7zsrc" -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Host "Extracting vmlinuz and initrd.gz from ISO using 7-Zip..." -ForegroundColor Green

    # Debian 12 ISO layout: install.amd\vmlinuz and install.amd\initrd.gz
    & $sevenZipExe e "$debianIso" "install.amd\vmlinuz" "install.amd\initrd.gz" -o"$workDir\tftp" -y | Out-Null

    if ((Test-Path "$workDir\tftp\vmlinuz") -and (Test-Path "$workDir\tftp\initrd.gz")) {
        Write-Host "Boot files extracted successfully with 7-Zip." -ForegroundColor Green
    } else {
        Write-Host "ERROR: Failed to extract boot files from ISO." -ForegroundColor Red
        exit 1
    }

    # Create virtual disk
    Write-Host "Creating virtual disk ($VMSize)..." -ForegroundColor Yellow
    & .\qemu\qemu-img.exe create -f qcow2 "$workDir\$VMName.qcow2" $VMSize

    # QEMU arguments
    $qemuArgs = @(
        "-name", $VMName,
        "-m", $Memory,
        "-smp", $CPUs,
        "-drive", "`"file=$workDir\$VMName.qcow2,format=qcow2,if=virtio`"",
        "-cdrom", "`"$debianIso`"",
        "-netdev", "user,id=net0,tftp=..\tftp,hostfwd=tcp::3388-:3389",
        "-device", "virtio-net,netdev=net0",
        "-kernel", "`"$workDir\tftp\vmlinuz`"",
        "-initrd", "`"$workDir\tftp\initrd.gz`"",
        "-append", "`"auto=true priority=critical url=tftp://10.0.2.2/preseed.cfg interface=auto netcfg/dhcp_timeout=60 debian-installer/allow_unauthenticated_ssl=true --- quiet `" ",
        "-boot", "order=dc",
        "-machine", "pc,kernel-irqchip=off",
        "-accel", "$Global:bestAccel"
    )

    Write-Host "Starting QEMU..." -ForegroundColor Green
    Start-Process -FilePath ".\qemu\qemu-system-x86_64.exe" `
                  -ArgumentList $qemuArgs `
                  -WorkingDirectory ".\qemu\" `
                  -RedirectStandardOutput RedirectStandardOutput.txt `
                  -RedirectStandardError RedirectStandardError.txt `
                  -NoNewWindow -Wait

    Write-Host "Debian Install Complete!" -ForegroundColor Green
}

function StartQEMU {
    param([string]$VMName = "debian-vm")
    $qcowFile = "$workDir\$VMName.qcow2"
    if (Test-Path $qcowFile) {
        Write-Host "Starting existing VM..." -ForegroundColor Green
        $qemuArgs = @(
            "-name", $VMName,
            "-m", $Memory,
            "-drive", "`"file=$qcowFile,format=qcow2,if=virtio`"",
            "-netdev", "user,id=net0,hostfwd=tcp::3388-:3389",
            "-device", "virtio-net,netdev=net0",
            "-accel", "$Global:bestAccel"
        )
        Start-Process -FilePath ".\qemu\qemu-system-x86_64.exe" `
                      -ArgumentList $qemuArgs `
                      -WorkingDirectory ".\qemu\" `
                      -NoNewWindow -Wait
    } else {
        Write-Host "No VM found. Run the script again to install." -ForegroundColor Red
    }
}

# Deploy UltraVNC from the UltraVNC_1830.zip package (no installer, no admin).
# Extracts the x64 winvnc.exe + required DLLs, enables portable mode, and writes
# a minimal ultravnc.ini (port 3389, password auth) so it runs headless.
function Install-UltraVNC {
    $uvncDir = "$workDir\UltraVNC"
    $uvncExe = "$uvncDir\winvnc.exe"

    if (Test-Path $uvncExe) {
        Write-Host "UltraVNC exists" -ForegroundColor Green
        return
    }

    Write-Host "Downloading UltraVNC 1.8.3.0 zip..." -ForegroundColor Yellow
    $uvncUrl = "https://uvnc.eu/download/1800/UltraVNC_1830.zip"
    $uvncZip = "$workDir\_UltraVNC.zip"
    (New-Object System.Net.WebClient).DownloadFile($uvncUrl, $uvncZip)

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    if (-not ([IO.Directory]::Exists($uvncDir))) { New-Item -ItemType Directory -Path $uvncDir | Out-Null }

    # Extract the whole zip, then take the x64 binaries (matches this OS).
    [System.IO.Compression.ZipFile]::ExtractToDirectory($uvncZip, "$workDir\_UltraVNC")
    Remove-Item $uvncZip -Force

    $src = "$workDir\_UltraVNC\x64"
    if (-not (Test-Path $src)) { $src = "$workDir\_UltraVNC\x86" }

    $dlls = @("winvnc.exe","vnchooks.dll","ddengine64.dll","ddengine.dll","logging.dll",
              "authSSP.dll","ldapauth.dll","workgrpdomnt4.dll","authadmin.dll","logmessages.dll",
              "SecureVNCPlugin64.dsm","SecureVNCPlugin.dsm")
    foreach ($d in $dlls) {
        $srcFile = Join-Path $src $d
        if (Test-Path $srcFile) { Copy-Item $srcFile (Join-Path $uvncDir $d) -Force }
    }
    Remove-Item "$workDir\_UltraVNC" -Recurse -Force -ErrorAction SilentlyContinue

    # Portable mode: config lives next to winvnc.exe (no admin, no AppData/ProgramData).
    New-Item -Path (Join-Path $uvncDir "ultravnc.portable") -ItemType File -Force | Out-Null

    # Minimal config: VNC on port 3389 with password auth.
    $ini = @"
[main]
Protocols=RTMP
[ultravnc]
PortNumber=3389
qos=0
deferinput=0
enableai=0
autowin=0
FileTransferEncoding=Base64
[ultravncPW]
Password=ZTtTTEj7Rzs
Password2=
[ultravncLang]
Lang=eng
"@
    $ini | Out-File -FilePath (Join-Path $uvncDir "ultravnc.ini") -Encoding ASCII

    Write-Host "UltraVNC deployed to $uvncDir" -ForegroundColor Green
}

function StartUltraVNC {
    $uvncExe = "$workDir\UltraVNC\winvnc.exe"
    if (-not (Test-Path $uvncExe)) {
        Write-Host "winvnc.exe not found." -ForegroundColor Red
        return
    }
    if (Get-Process -Name winvnc -ErrorAction SilentlyContinue) {
        Write-Host "UltraVNC already running" -ForegroundColor Green
        return
    }
    Write-Host "Starting UltraVNC..." -ForegroundColor Yellow
    Start-Process -FilePath $uvncExe -NoNewWindow
    Start-Sleep -Seconds 2
    if (Get-Process -Name winvnc -ErrorAction SilentlyContinue) {
        Write-Host "UltraVNC listening on port 3389" -ForegroundColor Green
    } else {
        Write-Host "WARNING: UltraVNC started but may have exited." -ForegroundColor Red
    }
}

function CHECKUVNC {
    Install-UltraVNC
    StartUltraVNC
}

function CheckAndStartQEMU {
    $qcowFiles = Get-ChildItem -Path "." -Filter "*.qcow2"
    if ($qcowFiles.Count -gt 0) {
        Write-Host "Existing VM found. Starting..." -ForegroundColor Green
        StartQEMU
    } else {
        Write-Host "No VM found. Installing new Debian VM..." -ForegroundColor Yellow
        Install-DebianVM
    }
}

# === Main ===
CheckAccel
CHECKUVNC
CheckAndStartQEMU
