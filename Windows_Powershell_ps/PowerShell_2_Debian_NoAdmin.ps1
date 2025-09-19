# without local admin this script will download and install Debian 12
# todo: 
# * fix gpu check
# * auto mount HOST c:\
# * auto rev tunnel if conf file
# * disable screensaver lock bpytop etc
# check for UVNC https://uvnc.eu/download/1640/UltraVNC_1640.zip 
# Stop any existing jobs and processes

#Get-Job | Stop-Job -PassThru | Remove-Job
#Stop-Process -Name powershell -Force -ErrorAction SilentlyContinue 2>$null
#Stop-Process -Name qemu-system-x86_64 -Force -ErrorAction SilentlyContinue 2>$null
#Start-Sleep 3

# Create working directory
$workDir = "C:\QEMU-Debian"
New-Item -ItemType Directory -Path $workDir -Force | Out-Null
Set-Location $workDir

# Add QEMU to PATH for current session
$qemuPath = "$workDir\qemu"
$env:PATH += ";$qemuPath"

# User-specified download function
function downloadFile($url, $file) {
    $req = [System.Net.HttpWebRequest]::Create($url)
    $res = $req.GetResponse().GetResponseStream()
    $fs = [System.IO.FileStream]::new($file, 'Create')
    $buf = [byte[]]::new(10KB)
    while (($c = $res.Read($buf, 0, $buf.Length)) -gt 0) {
        $fs.Write($buf, 0, $c)
    }
    $fs.Close()
    $res.Close()
}

# Download Debian ISO
$debianUrl = "https://cloud.debian.org/images/archive/12.7.0/amd64/iso-cd/debian-12.7.0-amd64-netinst.iso"
$debianIso = "$workDir\debian-12.7.0-amd64-netinst.iso"
if (Test-Path $debianIso) {
    Write-Host "Debian ISO exists" -ForegroundColor Yellow
} else {
     Write-Host "Downloading Debian ISO..." -ForegroundColor Yellow
    downloadFile $debianUrl $debianIso
}

# Download QEMU for Windows
$qemuUrl = "https://qemu.weilnetz.de/w64/qemu-w64-setup-20250826.exe"
$qemuInstaller = "$workDir\qemu-installer.exe"

if (Test-Path .\qemu\qemu-system-x86_64.exe) {
    Write-Host "QEMU Exists" -ForegroundColor Yellow
} else {
    Write-Host "Downloading QEMU" -ForegroundColor Yellow
    downloadFile $qemuUrl $qemuInstaller

    Write-Host "Installing QEMU..." -ForegroundColor Green
    $env:__COMPAT_LAYER = "RUNASINVOKER"
    Start-Process -FilePath $qemuInstaller -ArgumentList "/S", "/D=$workDir\qemu\" -Wait -NoNewWindow  
}

function Install-DebianVM {
    param(
        [string]$VMName = "debian-vm",
        [string]$VMSize = "200G",
        [int]$Memory = 6144,
        [int]$CPUs = 2,
        [string]$ISOPath = ".\debian-12.7.0-amd64-netinst.iso"
    )

    # Create TFTP directory for QEMU
    $tftpDir = "$workDir\tftp"
    New-Item -ItemType Directory -Path $tftpDir -Force | Out-Null

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

############################################################################################################################################################################################################################################################
### Package Selection - Standard with XFCE Desktop
tasksel tasksel/first multiselect standard, desktop, xfce-desktop, ssh-server
d-i pkgsel/include string openssh-server curl wget vim nano htop net-tools sudo build-essential git xfce4 xfce4-goodies lightdm firefox-esr thunar-archive-plugin
d-i pkgsel/upgrade select full-upgrade
d-i pkgsel/update-policy select unattended-upgrades

### Boot Loader
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean true
d-i grub-installer/bootdev string default

### Post-Installation Commands
##########d-i preseed/late_command string \
##########in-target usermod -aG sudo internet ; \
##########in-target systemctl enable ssh ; \
##########in-target systemctl enable lightdm ; \
##########in-target sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config ; \
##########in-target sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config ; \
##########in-target echo 'internet ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers.d/internet
############################################################################################################################################################################################################################################################

### Finish Installation
d-i finish-install/reboot_in_progress note
d-i debian-installer/exit/poweroff boolean true

### Additional Configuration
d-i hw-detect/load_firmware boolean true
popularity-contest popularity-contest/participate boolean false
"@

    # Save preseed to TFTP directory
    $preseedPath = "$tftpDir\preseed.cfg"
    $preseedContent | Out-File -FilePath $preseedPath -Encoding UTF8

    # Extract kernel and initrd from ISO for network boot
    Write-Host "Extracting boot files from ISO..." -ForegroundColor Green

    # Mount ISO and extract boot files
    $mountResult = Mount-DiskImage -ImagePath (Resolve-Path $ISOPath).Path -PassThru
    $driveLetter = ($mountResult | Get-Volume).DriveLetter

    if ($driveLetter) {
        Copy-Item "${driveLetter}:\install.amd\vmlinuz" "$tftpDir\vmlinuz" -Force
        Copy-Item "${driveLetter}:\install.amd\initrd.gz" "$tftpDir\initrd.gz" -Force
        Dismount-DiskImage -ImagePath (Resolve-Path $ISOPath).Path

        # Create virtual disk
        $diskPath = ".\$VMName.qcow2"
        Write-Host "Creating virtual disk ($VMSize)..." -ForegroundColor Green
        & .\qemu\qemu-img.exe create -f qcow2 $diskPath $VMSize

        # QEMU arguments with TFTP server and network boot                    
        $qemuArgs = @(
            "-name", $VMName,
            "-m", $Memory,
            "-smp", $CPUs,
            "-drive", "file=$diskPath,format=qcow2,if=virtio",
            "-cdrom", $ISOPath,
            "-netdev", "user,id=net0,tftp=$tftpDir,hostfwd=tcp::2222-:22",
            "-device", "virtio-net,netdev=net0",
            "-kernel", "$tftpDir\vmlinuz",
            "-initrd", "$tftpDir\initrd.gz",
            "-append", "auto=true priority=critical url=tftp://10.0.2.2/preseed.cfg interface=auto netcfg/dhcp_timeout=60 debian-installer/allow_unauthenticated_ssl=true console=ttyS0,115200n8 --- quiet",
            "-boot", "order=cdn",
            "-machine", "pc,kernel-irqchip=off",
            "-nographic",
            "-accel", "$Global:bestAccel"
        )

        Write-Host "Starting QEMU with TFTP server..." -ForegroundColor Green
        Write-Host "TFTP Directory: $tftpDir" -ForegroundColor Cyan
        Write-Host "Preseed available at: tftp://10.0.2.2/preseed.cfg" -ForegroundColor Cyan

        & .\qemu\qemu-system-x86_64.exe @qemuArgs

        #Write-Host "Installation completed! VM disk created at: $diskPath" -ForegroundColor Green
        #Write-Host "SSH access: ssh -p 2222 internet@localhost" -ForegroundColor Yellow
        #Write-Host "Password: password" -ForegroundColor Yellow

    } else {
        Write-Error "Failed to mount ISO file"
    }
}
 ################################################################################################################################################################ 

function CheckAccel {
# Create script to start VM without ISO (after installation)
Write-Host "Checking QEMU acceleration support..." -ForegroundColor Yellow

    # Get available accelerators from QEMU
 
        $accelOutput = & .\qemu\qemu-system-x86_64.exe -accel help 2>&1
        $availableAccels = @()

        # Parse output - look for lines after "Accelerators supported in QEMU binary:"
        $foundHeader = $false
        foreach ($line in $accelOutput) {
            if ($line -match "Accelerators supported in QEMU binary:") {
                $foundHeader = $true
                continue
            }

            # If we found the header, collect accelerator names
            if ($foundHeader -and $line.Trim() -ne "") {
                $accel = $line.Trim()
                if ($accel -match "^[a-zA-Z]+$") {  # Only letters, no spaces
                    $availableAccels += $accel
                }
            }
        }

        Write-Host "Available accelerators: $($availableAccels -join ', ')" -ForegroundColor Cyan

        # Determine best accelerator (priority order: whpx > hax > tcg)
        $Global:bestAccel = $null
        $accelerationStatus = $null

        if ($availableAccels -contains "whpx") {
            $Global:bestAccel = "whpx"
            $accelerationStatus = "Using WHPX (Windows Hypervisor Platform) - Fastest hardware acceleration"
            Write-Host $accelerationStatus -ForegroundColor Green
        }
        elseif ($availableAccels -contains "hax") {
            $Global:bestAccel = "hax" 
            $accelerationStatus = "Using HAXM (Intel Hardware Acceleration) - Fast hardware acceleration"
            Write-Host $accelerationStatus -ForegroundColor Green
        }
        elseif ($availableAccels -contains "tcg") {
            $Global:bestAccel = "tcg"
            $accelerationStatus = "WARNING: Only TCG (software emulation) available - No hardware acceleration!"
            Write-Host $accelerationStatus -ForegroundColor Red
        }
        else {
            Write-Host "ERROR: No accelerators found!" -ForegroundColor Red
            return
        }
}

function StartQEMU {
    param(
        [string]$VMName = "debian-vm",
        [string]$VMSize = "200G",
        [int]$Memory = 6144,
        [int]$CPUs = 2,
        [string]$ISOPath = ".\debian-12.7.0-amd64-netinst.iso"
    )

$diskPath = ".\$VMName.qcow2"
        $qemuArgs = @(
            "-name", $VMName,
            "-m", $Memory,
            "-smp", $CPUs,
            "-drive", "file=$diskPath,format=qcow2,if=virtio",
            "-cdrom", $ISOPath,
            "-netdev", "user,id=net0,tftp=$tftpDir,hostfwd=tcp::2222-:22,smb=C:\",
            "-device", "virtio-net,netdev=net0",
            "-boot", "order=cdn",
            "-machine", "pc,kernel-irqchip=off",
            "-vga", "std",
            "-vnc", "localhost:1",
            "-accel", "$Global:bestAccel" 
        )

Write-Host "Starting QEMU with $qemuArgs" -ForegroundColor Green
Write-Host "Connect to the host with VNC on localhost:5901" -ForegroundColor Yellow
$qemuProcess = Start-Process -FilePath ".\qemu\qemu-system-x86_64.exe" -ArgumentList $qemuArgs -WindowStyle hidden -PassThru
}



 ################################################################################################################################################################ 

# check accel
CheckAccel


# Search for .qcow2 files in current directory
$qcowFiles = Get-ChildItem -Path "." -Filter "*.qcow2"

if ($qcowFiles.Count -gt 0) {
    Write-Host "Found $($qcowFiles.Count) QCOW2 file(s)"
    foreach ($file in $qcowFiles) {
        Write-Host "Found: $($file.Name)"
    }
    StartQEMU
    exit
} else {
    Write-Host "No QCOW2 files found in current directory installing" -ForegroundColor Yellow
    Install-DebianVM  

}

 


