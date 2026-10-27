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
        # The -accel help output goes to stderr, so capture both streams into a
        # variable; matching against the captured text is far more reliable than
        # matching the raw stderr stream objects.
        $accelOut = "$workDir\_accel_help.txt"
        $accelTest = (& ".\qemu\qemu-system-x86_64w.exe" -accel help 2>&1 | Out-String)
        if ($accelTest -like "*whpx*") { $Global:bestAccel = "whpx" }
        elseif ($accelTest -like "*hax*") { $Global:bestAccel = "hax" }
        elseif ($accelTest -like "*hvf*")  { $Global:bestAccel = "hvf" }
        $accelTest | Out-File -FilePath $accelOut -Encoding ASCII
        Remove-Item $accelOut -Force -ErrorAction SilentlyContinue
    }
    Write-Host "Using acceleration: $Global:bestAccel" -ForegroundColor Cyan
}

# Acquires portable 7-Zip (no admin) and extracts the Debian kernel + initrd from the ISO.
# Idempotent: the 7-Zip binaries are cached, and the caller decides whether to call this.
function Install-DebianBootFiles {
    param([string]$ISOPath = $debianIso)

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
    & $sevenZipExe e "$ISOPath" "install.amd\vmlinuz" "install.amd\initrd.gz" -o"$workDir\tftp" -y | Out-Null

    if ((Test-Path "$workDir\tftp\vmlinuz") -and (Test-Path "$workDir\tftp\initrd.gz")) {
        Write-Host "Boot files extracted successfully with 7-Zip." -ForegroundColor Green
    } else {
        Write-Host "ERROR: Failed to extract boot files from ISO." -ForegroundColor Red
        exit 1
    }
}

function Install-DebianVM {
    param(
        [string]$VMName = "debian-vm",
        [string]$VMSize = "200G",
        [int]$Memory = $Global:Memory,
        [int]$CPUs = 1,
        [string]$ISOPath = "$Global:debianIso"
    )
	# Create TFTP directory for QEMU
   
    New-Item -ItemType Directory -Path "$workDir\tftp" -Force | Out-Null

    # Completely rewritten preseed content with modern practices
    $preseedContent = @"
### Localization and Language
d-i debian-installer/locale string en_US.UTF-8
d-i localechooser/supported-locales multiselect en_US.UTF-8
d-i keyboard-configuration/xkb-keymap select us

### Network Configuration
d-i netcfg/choose_interface select auto
d-i netcfg/disable_autoconfig boolean false
d-i netcfg/get_hostname string debian-auto
d-i netcfg/get_domain string localdomain

### APT and Mirror Configuration
d-i mirror/country string manual
d-i mirror/http/hostname string deb.debian.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string
d-i apt-setup/non-free boolean true
d-i apt-setup/contrib boolean true
d-i apt-setup/services-select multiselect security, updates
d-i apt-setup/security_host string security.debian.org

### Account Setup - Modern approach with sudo user
d-i passwd/root-login boolean false
d-i passwd/make-user boolean true
d-i passwd/user-fullname string internet
d-i passwd/username string internet
d-i passwd/user-password password password
d-i passwd/user-password-again password password
d-i user-setup/allow-password-weak boolean true
d-i user-setup/encrypt-home boolean false

### Clock and Timezone
d-i clock-setup/utc boolean true
d-i time/zone string UTC
d-i clock-setup/ntp boolean true
d-i clock-setup/ntp-server string pool.ntp.org

### Partitioning - Use entire disk with LVM
d-i partman-auto/method string lvm
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman-auto-lvm/guided_size string max
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

### Base System
d-i base-installer/install-recommends boolean true
d-i base-installer/kernel/image string linux-image-amd64

### Package Selection - Standard with XFCE Desktop
tasksel tasksel/first multiselect standard, desktop, xfce-desktop, ssh-server
d-i pkgsel/include string openssh-server curl wget vim nano htop net-tools sudo build-essential git xfce4 xfce4-goodies lightdm firefox-esr thunar-archive-plugin screen xclip bpytop
d-i pkgsel/upgrade select full-upgrade
d-i pkgsel/update-policy select unattended-upgrades

### Boot Loader
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i grub-installer/bootdev string default

### Post-Installation Commands
d-i preseed/late_command string \
in-target usermod -aG sudo internet ; \
in-target systemctl enable ssh ; \
in-target systemctl enable lightdm ; \
in-target sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config ; \
in-target sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config ; \
in-target mkdir -p /etc/sudoers.d ; \
in-target echo 'internet ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/internet ; \
in-target mkdir -p /home/internet/.config/xfce4/xfconf/xfce-perchannel-xml ; \
in-target chown -R internet:internet /home/internet/.config ; \
in-target echo '<?xml version="1.0" encoding="UTF-8"?><channel name="xfce4-power-manager" version="1.0"><property name="xfce4-power-manager" type="empty"><property name="power-button-action" type="uint" value="4"/><property name="sleep-button-action" type="uint" value="4"/><property name="hibernate-button-action" type="uint" value="4"/><property name="lid-action-on-battery" type="uint" value="4"/><property name="lid-action-on-ac" type="uint" value="4"/><property name="brightness-on-ac" type="uint" value="9"/><property name="brightness-on-battery" type="uint" value="9"/><property name="dpms-enabled" type="bool" value="false"/><property name="dpms-on-ac-sleep" type="uint" value="0"/><property name="dpms-on-ac-off" type="uint" value="0"/><property name="dpms-on-battery-sleep" type="uint" value="0"/><property name="dpms-on-battery-off" type="uint" value="0"/><property name="lock-screen-suspend-hibernate" type="bool" value="false"/><property name="logind-handle-lid-switch" type="bool" value="false"/><property name="logind-handle-power-key" type="bool" value="false"/><property name="logind-handle-suspend-key" type="bool" value="false"/><property name="logind-handle-hibernate-key" type="bool" value="false"/></property></channel>' > /home/internet/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml ; \
in-target echo '<?xml version="1.0" encoding="UTF-8"?><channel name="xfce4-screensaver" version="1.0"><property name="saver" type="empty"><property name="enabled" type="bool" value="false"/><property name="idle-activation" type="empty"><property name="enabled" type="bool" value="false"/></property></property></channel>' > /home/internet/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-screensaver.xml ; \
in-target chown internet:internet /home/internet/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml ; \
in-target chown internet:internet /home/internet/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-screensaver.xml ; \
in-target systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target ; \
in-target echo 'HandleLidSwitch=ignore' >> /etc/systemd/logind.conf ; \
in-target echo 'HandlePowerKey=ignore' >> /etc/systemd/logind.conf ; \
in-target echo 'HandleSuspendKey=ignore' >> /etc/systemd/logind.conf ; \
in-target echo 'HandleHibernateKey=ignore' >> /etc/systemd/logind.conf ; \
in-target echo 'xset s off -dpms' >> /home/internet/.xprofile ; \
in-target chown internet:internet /home/internet/.xprofile ; \
in-target sed -i 's/#autologin-user=/autologin-user=internet/' /etc/lightdm/lightdm.conf ; \
in-target sed -i 's/#autologin-user-timeout=0/autologin-user-timeout=0/' /etc/lightdm/lightdm.conf ; \
in-target sed -i 's/#autologin-session=/autologin-session=xfce/' /etc/lightdm/lightdm.conf
in-target mkdir -p /mnt/host ; \
in-target mount -t 9p -o trans=virtio,version=9p2000.L,rw,mmap,security_model=mapped-file host0 /mnt/host ; \
in-target echo 'host0 /mnt/host 9p trans=virtio,rw,mmap,security_model=mapped-file 0 0' >> /etc/fstab ; \

### Finish Installation
d-i finish-install/reboot_in_progress note
d-i debian-installer/exit/poweroff boolean true

### Additional Configuration
d-i hw-detect/load_firmware boolean true
popularity-contest popularity-contest/participate boolean false
"@


    # Save preseed to TFTP directory
 
    $preseedContent | Out-File -FilePath "$workDir\tftp\preseed.cfg" -Encoding UTF8

    # Extract kernel and initrd from ISO for network boot
    Write-Host "Extracting boot files from ISO..." -ForegroundColor Green

    # Mount ISO and extract boot files
    $mountResult = Mount-DiskImage -ImagePath (Resolve-Path $ISOPath).Path -PassThru
    $driveLetter = ($mountResult | Get-Volume).DriveLetter

    if ($driveLetter) {
        Copy-Item "${driveLetter}:\install.amd\vmlinuz" "$workDir\tftp\vmlinuz" -Force
        Copy-Item "${driveLetter}:\install.amd\initrd.gz" "$workDir\tftp\initrd.gz" -Force
        Dismount-DiskImage -ImagePath (Resolve-Path $ISOPath).Path

        # Create virtual disk
        Write-Host "Creating virtual disk ($VMSize)..." -ForegroundColor Yellow
        & .\qemu\qemu-img.exe create -f qcow2 "$workDir\$VMName.qcow2" $VMSize

        # QEMU arguments with TFTP server and network boot                    
 
        $qemuArgs = @(
            "-name", $VMName,
            "-m", $Global:Memory,
            "-smp", $CPUs,
            "-drive", "`"file=$workDir\$VMName.qcow2,format=qcow2,if=virtio`"",
            "-cdrom", "`"$Global:debianIso`"",
            "-netdev", "user,id=net0,tftp=..\tftp,hostfwd=tcp::3388-:3389",
            "-device", "virtio-net,netdev=net0",
            "-kernel", "`"$workDir\tftp\vmlinuz`"",
            "-initrd", "`"$workDir\tftp\initrd.gz`"",
            "-append", "`"auto=true priority=critical url=tftp://10.0.2.2/preseed.cfg interface=auto netcfg/dhcp_timeout=60 debian-installer/allow_unauthenticated_ssl=true --- quiet `" ",
            "-boot", "order=dc",
            "-machine", "pc,kernel-irqchip=off",
            "-accel", "$Global:bestAccel"
        )
		Write-Host "Starting QEMU with qemu-system-x86_64.exe $qemuArgs" -ForegroundColor Green
		Write-Host "Installing Debian with ISO $Global:debianIso and Image $workDir\$VMName.qcow2 " -ForegroundColor Green
		Start-Process -FilePath ".\qemu\qemu-system-x86_64.exe" -ArgumentList $qemuArgs -WorkingDirectory ".\qemu\" -RedirectStandardOutput RedirectStandardOutput.txt -RedirectStandardError RedirectStandardError.txt -NoNewWindow -wait
		Write-Host "Debian Install Complete! Run this script again to start the image!" -ForegroundColor Green
		CheckAndStartQEMU
    } else {
        Write-Error "Failed to mount ISO file"
    }
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
            "-netdev", "user,id=net0,hostfwd=tcp::2222-:22",
            "-device", "virtio-net,netdev=net0",
            "-accel", "$Global:bestAccel",
            "-display", "gtk",
            "-L", "$workDir\qemu"
        )
        Start-Process -FilePath ".\qemu\qemu-system-x86_64.exe" `
                      -ArgumentList $qemuArgs `
                      -WorkingDirectory ".\qemu\" 
    } else {
        Write-Host "No VM found. Run the script again to install." -ForegroundColor Red
    }
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

CheckAndStartQEMU
