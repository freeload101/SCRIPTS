# without local admin this script will download and install Debian 12
# todo: 
# * auto mount HOST c:\
# * auto rev tunnel if conf file
# * disable screensaver lock   etc
 

# Create working directory
$workDir = (Get-Location)
New-Item -ItemType Directory -Path $workDir -Force | Out-Null
Set-Location $workDir

# Add QEMU to PATH for current session
$qemuPath = "$workDir\qemu"
$env:PATH += ";$qemuPath"

# User-specified download function
function downloadFile($url, $file) {
    $request = [System.Net.HttpWebRequest]::Create($url)

    # Set current User-Agent (Chrome on Windows)
    $request.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"

    # Set Referrer
    $request.Referer = "https://qemu.weilnetz.de/w64/"

    # Use properties for restricted headers instead of Headers.Add()
    $request.Accept = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
    $request.KeepAlive = $true  # Use property instead of Connection header

    # Safe headers that can be added
    $request.Headers.Add("Accept-Language", "en-US,en;q=0.5")
    $request.Headers.Add("Accept-Encoding", "gzip, deflate")
    $request.Headers.Add("DNT", "1")
    $request.Headers.Add("Upgrade-Insecure-Requests", "1")

    $response = $request.GetResponse()
    $responseStream = $response.GetResponseStream()
    $fileStream = [System.IO.FileStream]::new($file, 'Create')

    $responseStream.CopyTo($fileStream)

    $fileStream.Close()
    $responseStream.Close()
    $response.Close()
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

        Write-Host "Connect to the host with VNC on localhost:5901" -ForegroundColor Yellow
		start-sleep 10

    } else {
        Write-Error "Failed to mount ISO file"
    }
}
  

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
            "-device", "usb-ehci",
			"-device", "usb-tablet",
            "-accel", "$Global:bestAccel" 
        )

Write-Host "Starting QEMU with $qemuArgs" -ForegroundColor Green
Write-Host "Connect to the host with VNC on localhost:5901" -ForegroundColor Yellow
start-sleep 10
$qemuProcess = Start-Process -FilePath ".\qemu\qemu-system-x86_64.exe" -ArgumentList $qemuArgs -WindowStyle hidden -PassThru
}


function CHECKUVNC {
    # Check if UVNC directory exists
    $uvncPath = "$workDir\UVNC"

    if (!(Test-Path $uvncPath)) {
        Write-Host "UltraVNC not found. Downloading and installing..." -ForegroundColor Yellow

        # Create directory structure
        New-Item -Path "$workDir\UVNC" -ItemType Directory -Force | Out-Null

        # Download the zip file
        $zipFile = "$workDir\UltraVNC_1640.zip"
        $downloadUrl = "https://uvnc.eu/download/1640/UltraVNC_1640.zip"

        try {
            downloadFile $downloadUrl $zipFile
            Write-Host "Download completed successfully." -ForegroundColor Green

            # Extract the zip file
            Expand-Archive -Path $zipFile -DestinationPath "$workDir\temp_uvnc" -Force

            # Create UVNC directory
            New-Item -Path $uvncPath -ItemType Directory -Force | Out-Null

            # Find and copy the executable files (portable installation)
            $tempPath = "$workDir\temp_uvnc"
            $executableFiles = Get-ChildItem -Path $tempPath -Recurse -Include "*.exe", "*.dll" -ErrorAction SilentlyContinue

            foreach ($file in $executableFiles) {
                Copy-Item $file.FullName -Destination $uvncPath -Force
            }

            # Clean up
            Remove-Item $zipFile -Force -ErrorAction SilentlyContinue
            Remove-Item "$workDir\temp_uvnc" -Recurse -Force -ErrorAction SilentlyContinue

            & "C:\QEMU-Debian\UVNC\vncviewer.exe" localhost::5901  

        } catch {
            Write-Error "Failed to download or extract UltraVNC: $($_.Exception.Message)"
            exit 1
        }
    } else {
	Write-Host "Waiting 20 seconds to connect to QEMU VM" -ForegroundColor Yellow
	start-sleep 20
    & "C:\QEMU-Debian\UVNC\vncviewer.exe" localhost::5901  
    }
}

function CheckAndStartQEMU {
    if (-not (Get-Process -Name "qemu-system-x86_64" -ErrorAction SilentlyContinue)) {
        Write-Host "QEMU is not running. Starting QEMU..." -ForegroundColor Yellow
        StartQEMU
    } else {
        Write-Host "QEMU is already running." -ForegroundColor Green
    }
}



Main ################################################################################################################################################################ 

# check accel
CheckAccel

# Search for .qcow2 files in current directory
$qcowFiles = Get-ChildItem -Path "." -Filter "*.qcow2"

if ($qcowFiles.Count -gt 0) {
    Write-Host "Found $($qcowFiles.Count) QCOW2 file(s)"
    foreach ($file in $qcowFiles) {
        Write-Host "Found: $($file.Name)"
    }
    CheckAndStartQEMU
	CHECKUVNC
} else {
    Write-Host "No QCOW2 files found in current directory installing" -ForegroundColor Yellow
    Install-DebianVM
	start-sleep 10
	CHECKUVNC
}








 


