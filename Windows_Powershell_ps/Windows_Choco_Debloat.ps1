#Requires -RunAsAdministrator
Set-ExecutionPolicy Unrestricted -Force -Scope Process

$DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

#region === PART 1: Chocolatey_Cygwin (base setup) ===

# Account lockout policy
net accounts /lockoutthreshold:5 /lockoutduration:30 /lockoutwindow:30

# Time sync EST
w32tm /config /manualpeerlist:"time.windows.com,0x1" /syncfromflags:manual /reliable:yes /update
net stop w32time; net start w32time; w32tm /resync
Set-TimeZone -Id "Eastern Standard Time"

# Remove firewall popup nag
New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Force | Out-Null
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLgOnBoot' -Value 0

# Fix Win11 context menu
reg add "HKCU\Software\Classes\CLSID{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f

# Power/sleep settings
powercfg -restoredefaultschemes
powercfg /SETDCVALUEINDEX SCHEME_CURRENT 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0
powercfg /SETACVALUEINDEX SCHEME_CURRENT 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0
powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
@('hibernate-timeout-ac','hibernate-timeout-dc','disk-timeout-ac','disk-timeout-dc','monitor-timeout-ac','monitor-timeout-dc','standby-timeout-ac','standby-timeout-dc') | ForEach { powercfg /x "-$_" 0 }
powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_NONE CONSOLELOCK 0
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_NONE CONSOLELOCK 0

# Suppress shutdown dialogs
@{
    'HKCU:\Control Panel\Desktop' = @{AutoEndTasks='1';HungAppTimeout='1000';WaitToKillAppTimeout='2000';LowLevelHooksTimeout=1000}
    'HKLM:\System\CurrentControlSet\Control' = @{WaitToKillServiceTimeout='2000'}
    'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows' = @{ShutdownWarningDialogTimeout=1}
    'HKU:\.DEFAULT\Control Panel\Desktop' = @{AutoEndTasks='1'}
} | ForEach-Object { $p=$_.Key; $_.Value.GetEnumerator() | ForEach { Set-ItemProperty -Path $p -Name $_.Key -Value $_.Value -Force -ErrorAction SilentlyContinue } }

# Download yt-dlp for all users
$tempPath = "$env:TEMP\yt-dlp.exe"
Invoke-WebRequest -Uri "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" -OutFile $tempPath -UseBasicParsing
$accessRule = [System.Security.AccessControl.FileSystemAccessRule]::new("Everyone","FullControl","Allow")
$adminsSid  = [System.Security.Principal.SecurityIdentifier]::new("S-1-5-32-544")
Get-CimInstance -ClassName Win32_UserProfile | Where-Object { -not $_.Special -and $_.LocalPath -notlike "*\Administrator" } | ForEach-Object {
    $targetDir  = Join-Path $_.LocalPath "AppData\Local\Microsoft\WindowsApps"
    $targetFile = Join-Path $targetDir "yt-dlp.exe"
    [void](New-Item -ItemType Directory -Path $targetDir -Force -ErrorAction SilentlyContinue)
    Copy-Item -Path $tempPath -Destination $targetFile -Force
    foreach ($path in @($targetFile,$targetDir)) {
        $acl = Get-Acl $path; $acl.SetAccessRule($accessRule); $acl.SetOwner($adminsSid); Set-Acl -Path $path -AclObject $acl
    }
}
Remove-Item $tempPath -Force -ErrorAction SilentlyContinue

# Set PS execution policy (base64: Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force)
powershell.exe -Enc UwBlAHQALQBFAHgAZQBjAHUAdABpAG8AbgBQAG8AbABpAGMAeQAgAC0ARQB4AGUAYwB1AHQAaQBvAG4AUABvAGwAaQBjAHkAIABVAG4AcgBlAHMAdAByAGkAYwB0AGUAZAAgAC0ARgBvAHIAYwBlAA==

# Install Chocolatey
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    (New-Object Net.WebClient).DownloadFile('https://chocolatey.org/install.ps1',"$DIR\install.ps1")
    & "$DIR\install.ps1"
}
$env:PATH += ";C:\ProgramData\chocolatey\bin"
choco upgrade chocolatey -y
choco feature enable -n allowGlobalConfirmation

# Optional: Chocolatey Pro license
if (Test-Path "$DIR\chocolatey.license.xml") {
    New-Item "C:\ProgramData\chocolatey\license" -ItemType Directory -Force | Out-Null
    Copy-Item "$DIR\chocolatey.license.xml" "C:\ProgramData\chocolatey\license\chocolatey.license.xml" -Force
    choco upgrade chocolatey.extension -y
}

# Core choco packages
foreach ($pkg in @('chocolateygui','winmerge','chromium','irfanview','irfanview-shellextension','irfanviewplugins','vlc','7zip','mobaxterm','nerd-fonts-hack','notepadplusplus','filezilla','gimp','teracopy','ffmpeg','audacity','doublecmd','windirstat')) {
    choco install $pkg -y; choco upgrade $pkg -y
}

# Optional Cygwin + extra apps prompt
$installCygwin = (Read-Host "Install Cygwin and optional apps? [Y/N] (5s timeout, default N)") -eq 'Y'
$runDebloat    = (Read-Host "Run Debloat/Hardening? [Y/N] (5s timeout, default N)") -eq 'Y'

if ($installCygwin) {
    foreach ($pkg in @('openshot','plexamp','veracrypt','libreoffice-fresh','teracopy','procexp','procmon')) {
        choco upgrade $pkg -y
    }
    # Cygwin Portable
    $cwInstaller = "$DIR\cygwin-portable-installer.cmd"
    (New-Object Net.WebClient).DownloadFile('https://github.com/vegardit/cygwin-portable-installer/raw/main/cygwin-portable-installer.cmd', $cwInstaller)
    cmd /c $cwInstaller
    (New-Object Net.WebClient).DownloadFile('https://github.com/transcode-open/apt-cyg/raw/master/apt-cyg', "$DIR\cygwin\bin\apt-cyg")
}

choco upgrade all -y
choco uninstall choco-upgrade-all-at-startup -y --force-dependencies -ErrorAction SilentlyContinue
choco install choco-upgrade-all-at-startup -y

#endregion

if (-not $runDebloat) { Write-Host "[+] All done!"; exit }

#region === PART 2: Win10/11 Hardening & Debloat ===

function sp($p,$n,$t,$v){ Set-ItemProperty -Path $p -Name $n -Type $t -Value $v -Force -ErrorAction SilentlyContinue }
function mk($p){ if(!(Test-Path $p)){ New-Item -Path $p -Force | Out-Null } }

# Disable GameBar/DVR
sp 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' 'AppCaptureEnabled' DWord 0
sp 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' 'GameDVR_Enabled' DWord 0
sp 'HKCU:\Software\Microsoft\GameBar' 'AllowAutoGameMode' DWord 0
sp 'HKCU:\Software\Microsoft\GameBar' 'AutoGameModeEnabled' DWord 0
Get-AppxPackage Microsoft.XboxGamingOverlay | Remove-AppxPackage -ErrorAction SilentlyContinue

# Disable Smart App Control
sp 'HKLM:\SYSTEM\CurrentControlSet\Control\CI\Policy' 'VerifiedAndReputablePolicyState' DWord 0

# Disable MS account sign-in
sp 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' 'NoMicrosoftAccount' DWord 1

# MSEdgeRedirect
$edgeRedirectUri = ((Invoke-RestMethod -Uri "https://api.github.com/repos/rcmaehl/MSEdgeRedirect/releases/latest").assets | Where-Object name -like '*.exe').browser_download_url
Invoke-WebRequest -Uri $edgeRedirectUri -OutFile "C:\windows\temp\MSEdgeRedirect.exe"
Start-Sleep -s 5
$setupIni = @'
[Config]
Managed=True
Mode=Active
[Settings]
Edges=Stable,Beta,Dev,Canary
NoApps=True
NoBing=True
NoImgs=True
NoMSN=True
NoPDFs=True
NoTray=True
NoUpdates=True
Images=Google
News=DuckDuckGo
PDFApp=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe
Search=Custom
SearchPath=https://kagi.com
StartMenu=AppOnly
Startup=False
Weather=Weather.gov
'@
$setupIni | Out-File -Encoding Ascii -FilePath "C:\windows\temp\Setup.ini" -ErrorAction SilentlyContinue
Start-Process -FilePath "C:\windows\temp\MSEdgeRedirect.exe" -ArgumentList '/silentinstall "C:\windows\temp\Setup.ini"'

# Edge removal
Invoke-WebRequest -Uri "https://github.com/AveYo/fox/raw/main/Edge_Removal.bat" -OutFile "C:\windows\temp\Edge_Removal.bat"
Start-Process -FilePath "C:\windows\temp\Edge_Removal.bat"; Start-Sleep -s 10

# Disable Chrome sign-in prompt
mk 'HKLM:\SOFTWARE\Policies\Google\Chrome'
sp 'HKLM:\SOFTWARE\Policies\Google\Chrome' 'BrowserSignin' DWord 0

# Disable system restore
Disable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue

# Edge startup boost
foreach ($p in @('HKCU:\SOFTWARE\Policies\Microsoft\Edge','HKCU:\SOFTWARE\Policies\Microsoft\Edge\Recommended','HKLM:\SOFTWARE\Policies\Microsoft\Edge','HKLM:\SOFTWARE\Policies\Microsoft\Edge\Recommended')) {
    mk $p; sp $p 'StartupBoostEnabled' DWord 0
}

# Start/run history
sp 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_TrackProgs' DWord 0
sp 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_TrackDocs' DWord 0

# Disable News/Interests
sp 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds' 'ShellFeedsTaskbarViewMode' DWord 2

# Disable Meet Now
mk 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'
sp 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'HideSCAMeetNow' DWord 1

# Remove Win11 bloat apps
foreach ($app in @('Clipchamp.Clipchamp','MicrosoftTeams','Microsoft.GamingApp','Microsoft.GetHelp','Microsoft.Getstarted','Microsoft.MicrosoftOfficeHub','Microsoft.MixedReality.Portal','Microsoft.People','Microsoft.PowerAutomateDesktop','Microsoft.Todos','Microsoft.Windows.Photos','Microsoft.WindowsAlarms','Microsoft.WindowsCamera','Microsoft.WindowsFeedbackHub','Microsoft.WindowsMaps','Microsoft.WindowsSoundRecorder','Microsoft.Xbox.TCUI','Microsoft.XboxApp','Microsoft.XboxGameOverlay','Microsoft.XboxGamingOverlay','Microsoft.XboxIdentityProvider','Microsoft.XboxSpeechToTextOverlay','Microsoft.ZuneMusic','Microsoft.ZuneVideo','MicrosoftCorporationII.MicrosoftFamily','MicrosoftCorporationII.QuickAssist','SpotifyAB.SpotifyMusic')) {
    Get-AppxPackage -AllUsers | Where-Object { $_.PackageFullName -like "*$app*" } | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like "*$app*" } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# Disable Copilot
foreach ($p in @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot','HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot')) { mk $p; sp $p 'TurnOffWindowsCopilot' DWord 1 }
Get-AppxPackage '*Windows.Copilot*' | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
Get-AppxPackage '*Microsoft.Copilot*' | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-AppxPackage '*Microsoft.Windows.Ai*' | Remove-AppxPackage -ErrorAction SilentlyContinue

# Disable Recall/AI
mk 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'
sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis' DWord 1
sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'TurnOffSavingSnapshots' DWord 1
sp 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowCopilotButton' DWord 0

# Disable Office Copilot
foreach ($app in @('Excel','Word','PowerPoint')) {
    $rp = "HKCU:\Software\Policies\Microsoft\Office\16.0\$app\DisabledCmdBarItemsList"
    mk $rp; sp $rp 'TCID1' String 'TabCopilot'
}
$fp = 'HKCU:\Software\Microsoft\Office\16.0\Common\ExperimentConfigs\ExternalFeatureOverrides\microsoft'
mk $fp
foreach ($n in @('Microsoft.Office.Copilot.Excel','Microsoft.Office.Copilot.Word','Microsoft.Office.Copilot.PowerPoint','Microsoft.Office.Copilot.OneNote')) { sp $fp $n String 'false' }
mk 'HKCU:\Software\Policies\Microsoft\Cloud\Office\16.0\common\privacy'
sp 'HKCU:\Software\Policies\Microsoft\Cloud\Office\16.0\common\privacy' 'controllerconnectedservicesenabled' DWord 2

# Disable ads/promos/tracking
$adKeys = @{
    'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' = @('SilentInstalledAppsEnabled','SystemPaneSuggestionsEnabled','SubscribedContent-338393Enabled','SubscribedContent-353694Enabled','SubscribedContent-353696Enabled','SubscribedContent-338388Enabled','ContentDeliveryAllowed','OemPreInstalledAppsEnabled','PreInstalledAppsEnabled','PreInstalledAppsEverEnabled','SubscribedContent-338387Enabled','SubscribedContent-338389Enabled','SubscribedContent-353698Enabled')
    'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' = @('DisableWindowsConsumerFeatures')
}
$adKeys.GetEnumerator() | ForEach-Object { $p=$_.Key; mk $p; $_.Value | ForEach { sp $p $_ DWord 0 } }

# Replace AI Notepad with Notepad2
Get-AppxPackage '*WindowsNotepad*' | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
$n2dir = "$env:ProgramFiles\Notepad2"; New-Item -ItemType Directory -Path $n2dir -Force | Out-Null
Invoke-WebRequest -Uri 'https://github.com/pbatard/notepad2/releases/download/v4.22.05r4280/Notepad2.exe' -OutFile "$n2dir\Notepad2.exe"
sp 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.txt\UserChoice' 'ProgId' String 'Applications\Notepad2.exe'

# Disable telemetry
foreach ($p in @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection','HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection','HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection')) { mk $p; sp $p 'AllowTelemetry' DWord 0 }
Stop-Service 'DiagTrack' -Force -ErrorAction SilentlyContinue; Set-Service 'DiagTrack' -StartupType Disabled -ErrorAction SilentlyContinue
Stop-Service 'dmwappushservice' -WarningAction SilentlyContinue; Set-Service 'dmwappushservice' -StartupType Disabled -ErrorAction SilentlyContinue
@('Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser','Microsoft\Windows\Application Experience\ProgramDataUpdater','Microsoft\Windows\Autochk\Proxy','Microsoft\Windows\Customer Experience Improvement Program\Consolidator','Microsoft\Windows\Customer Experience Improvement Program\UsbCeip','Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector','Microsoft\Windows\Feedback\Siuf\DmClient','Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload') | ForEach { Disable-ScheduledTask -TaskName $_ -ErrorAction SilentlyContinue | Out-Null }

# Privacy tweaks
sp 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'BingSearchEnabled' DWord 0
sp 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'CortanaConsent' DWord 0
mk 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'DisableWebSearch' DWord 1
sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'AllowCortana' DWord 0
mk 'HKCU:\SOFTWARE\Microsoft\Personalization\Settings'; sp 'HKCU:\SOFTWARE\Microsoft\Personalization\Settings' 'AcceptedPrivacyPolicy' DWord 0
mk 'HKCU:\SOFTWARE\Microsoft\InputPersonalization'
sp 'HKCU:\SOFTWARE\Microsoft\InputPersonalization' 'RestrictImplicitTextCollection' DWord 1
sp 'HKCU:\SOFTWARE\Microsoft\InputPersonalization' 'RestrictImplicitInkCollection' DWord 1
mk 'HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore'; sp 'HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore' 'HarvestContacts' DWord 0
foreach ($p in @('HKLM:\SOFTWARE\Policies\Microsoft\Windows\System')) { mk $p; sp $p 'EnableActivityFeed' DWord 0; sp $p 'PublishUserActivities' DWord 0; sp $p 'UploadUserActivities' DWord 0; sp $p 'EnableCdp' DWord 0; sp $p 'EnableMmx' DWord 0; sp $p 'DontDisplayNetworkSelectionUI' DWord 1 }
mk 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo'; sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' 'DisabledByGroupPolicy' DWord 1
sp 'HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting' 'Disabled' DWord 1
Disable-ScheduledTask -TaskName 'Microsoft\Windows\Windows Error Reporting\QueueReporting' -ErrorAction SilentlyContinue | Out-Null
mk 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; sp 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableTailoredExperiencesWithDiagnosticData' DWord 1
mk 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules'; sp 'HKCU:\SOFTWARE\Microsoft\Siuf\Rules' 'NumberOfSIUFInPeriod' DWord 0
sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'DoNotShowFeedbackNotifications' DWord 1
Get-ChildItem -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications' -Exclude 'Microsoft.Windows.Cortana*' | ForEach { sp $_.PsPath 'Disabled' DWord 1; sp $_.PsPath 'DisabledByUser' DWord 1 }
mk 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location'
sp 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location' 'Value' String 'Deny'
sp 'HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration' 'Status' DWord 0
sp 'HKLM:\SYSTEM\Maps' 'AutoUpdateEnabled' DWord 0

# Security tweaks
sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableSmartScreen' DWord 0
mk 'HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter'; sp 'HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter' 'EnabledV9' DWord 0
mk 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender'; sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender' 'DisableAntiSpyware' DWord 1
mk 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet'
sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet' 'SpynetReporting' DWord 0
sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet' 'SubmitSamplesConsent' DWord 2
Set-NetConnectionProfile -NetworkCategory Private -ErrorAction SilentlyContinue
bcdedit /set '{current}' nx OptOut | Out-Null
Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity' -Name 'Enabled' -ErrorAction SilentlyContinue
sp 'HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings' 'Enabled' DWord 0
sp 'HKLM:\SOFTWARE\Microsoft.NETFramework\v4.0.30319' 'SchUseStrongCrypto' DWord 1
sp 'HKLM:\SOFTWARE\Wow6432Node\Microsoft.NETFramework\v4.0.30319' 'SchUseStrongCrypto' DWord 1
mk 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat'; sp 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat' 'cadca5fe-87d3-4b96-b7fb-a231484277cc' DWord 0
mk 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'NoAutoRebootWithLoggedOnUsers' DWord 1
sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'AUPowerManagement' DWord 0
sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'NoAUShutdownOption' DWord 1
sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'NoAUAsDefaultShutdownOption' DWord 1
sp 'HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance' 'fAllowToGetHelp' DWord 0
sp 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' 'fDenyTSConnections' DWord 0
sp 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' 'UserAuthentication' DWord 0
Enable-NetFirewallRule -Name 'RemoteDesktop*' -ErrorAction SilentlyContinue
mk 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; sp 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoDriveTypeAutoRun' DWord 255
sp 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers' 'DisableAutoplay' DWord 1
Stop-Service 'HomeGroupListener' -WarningAction SilentlyContinue; Set-Service 'HomeGroupListener' -StartupType Disabled -ErrorAction SilentlyContinue
Stop-Service 'HomeGroupProvider' -WarningAction SilentlyContinue; Set-Service 'HomeGroupProvider' -StartupType Disabled -ErrorAction SilentlyContinue
Disable-ScheduledTask -TaskName 'Microsoft\Windows\Defrag\ScheduledDefrag' -ErrorAction SilentlyContinue | Out-Null
Stop-Service 'SysMain' -WarningAction SilentlyContinue; Set-Service 'SysMain' -StartupType Disabled -ErrorAction SilentlyContinue
Stop-Service 'WSearch' -WarningAction SilentlyContinue; Set-Service 'WSearch' -StartupType Disabled -ErrorAction SilentlyContinue

# UI tweaks
mk 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer'; sp 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'DisableNotificationCenter' DWord 1
sp 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications' 'ToastEnabled' DWord 0
mk 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'; sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization' 'NoLockScreen' DWord 1
sp 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'ShutdownWithoutLogon' DWord 0
sp 'HKCU:\Control Panel\Accessibility\StickyKeys' 'Flags' String '506'
sp 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' 'SearchboxTaskbarMode' DWord 0
sp 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowTaskViewButton' DWord 0
sp 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarSmallIcons' DWord 1
sp 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarGlomLevel' DWord 1
mk 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People'; sp 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People' 'PeopleBand' DWord 0
sp 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' 'EnableAutoTray' DWord 0
mk 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'NoUseStoreOpenWith' DWord 1
sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer' 'NoNewAppAlert' DWord 1
sp 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager' 'EnthusiastMode' DWord 1
mk 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'; sp 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'ConfirmFileDelete' DWord 1
sp 'HKCU:\Control Panel\Desktop' 'DragFullWindows' String 0
sp 'HKCU:\Control Panel\Desktop' 'MenuShowDelay' String 0
sp 'HKCU:\Control Panel\Desktop\WindowMetrics' 'MinAnimate' String 0
sp 'HKCU:\Control Panel\Keyboard' 'KeyboardDelay' DWord 0
sp 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ListviewAlphaSelect' DWord 0
sp 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ListviewShadow' DWord 0
sp 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'TaskbarAnimations' DWord 0
sp 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' 'VisualFXSetting' DWord 3
sp 'HKCU:\Software\Microsoft\Windows\DWM' 'EnableAeroPeek' DWord 0
sp 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'HideFileExt' DWord 0
sp 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Hidden' DWord 1
sp 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowSyncProviderNotifications' DWord 0
sp 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'ShowCopilotButton' DWord 0
sp 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'LaunchTo' DWord 1
sp 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'Start_TrackDocs' DWord 0
sp 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' 'ShowRecent' DWord 0
sp 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' 'ShowFrequent' DWord 0
sp 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'DisableThumbnailCache' DWord 1
sp 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'DisableThumbsDBOnNetworkFolders' DWord 1

# Show This PC on desktop
foreach ($k in @('ClassicStartMenu','NewStartPanel')) {
    mk "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\$k"
    sp "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\$k" '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' DWord 0
}

# Remove This PC folder clutter
foreach ($ns in @('{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}','{d3162b92-9365-467a-956b-92703aca08af}','{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}','{088e3905-0323-4b02-9826-5d99428e115f}','{374DE290-123F-4565-9164-39C4925E467B}','{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}','{1CF1260C-4DD0-4ebb-811F-33C572699FDE}','{24ad3ad4-a569-4530-98e1-ab02f9417aa8}','{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}','{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}','{A0953C92-50DC-43bf-BE83-3742FED03C9C}','{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}')) {
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace$ns" -Recurse -ErrorAction SilentlyContinue
}

# Disable OneDrive
mk 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive'; sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' 'DisableFileSyncNGSC' DWord 1
Stop-Process -Name 'OneDrive' -Force -ErrorAction SilentlyContinue; Start-Sleep -s 2
$od = if (Test-Path "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe") { "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe" } else { "$env:SYSTEMROOT\System32\OneDriveSetup.exe" }
Start-Process $od '/uninstall' -NoNewWindow -Wait -ErrorAction SilentlyContinue
Start-Sleep -s 2
@("$env:USERPROFILE\OneDrive","$env:LOCALAPPDATA\Microsoft\OneDrive","$env:PROGRAMDATA\Microsoft OneDrive","$env:SYSTEMDRIVE\OneDriveTemp") | ForEach { Remove-Item -Path $_ -Force -Recurse -ErrorAction SilentlyContinue }
if (!(Test-Path 'HKCR:')) { New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null }
Remove-Item -Path 'HKCR:\CLSID{018D5C66-4533-4307-9B53-224DE2ED1FE6}' -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path 'HKCR:\Wow6432Node\CLSID{018D5C66-4533-4307-9B53-224DE2ED1FE6}' -Recurse -ErrorAction SilentlyContinue

# Uninstall MS bloat
foreach ($app in @('Microsoft.3DBuilder','Microsoft.AppConnector','Microsoft.BingFinance','Microsoft.BingNews','Microsoft.BingSports','Microsoft.BingTranslator','Microsoft.BingWeather','Microsoft.CommsPhone','Microsoft.ConnectivityStore','Microsoft.GetHelp','Microsoft.Getstarted','Microsoft.Messaging','Microsoft.Microsoft3DViewer','Microsoft.MicrosoftOfficeHub','Microsoft.MicrosoftPowerBIForWindows','Microsoft.MicrosoftSolitaireCollection','Microsoft.MicrosoftStickyNotes','Microsoft.MinecraftUWP','Microsoft.MSPaint','Microsoft.NetworkSpeedTest','Microsoft.Office.OneNote','Microsoft.Office.Sway','Microsoft.OneConnect','Microsoft.People','Microsoft.Print3D','Microsoft.RemoteDesktop','Microsoft.SkypeApp','Microsoft.Wallet','Microsoft.WindowsAlarms','Microsoft.WindowsCamera','microsoft.windowscommunicationsapps','Microsoft.WindowsFeedbackHub','Microsoft.WindowsMaps','Microsoft.WindowsPhone','Microsoft.Windows.Photos','Microsoft.WindowsSoundRecorder','Microsoft.ZuneMusic','Microsoft.ZuneVideo','Microsoft.XboxApp','Microsoft.XboxIdentityProvider','Microsoft.XboxSpeechToTextOverlay','Microsoft.XboxGameOverlay','Microsoft.Xbox.TCUI','Microsoft.YourPhone','Microsoft.MixedReality.Portal','Microsoft.ScreenSketch','Microsoft.BingFoodAndDrink','Microsoft.BingHealthAndFitness','Microsoft.BingTravel','Microsoft.WindowsReadingList')) {
    Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object DisplayName -EQ $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# Uninstall third-party bloat
foreach ($app in @('2414FC7A.Viber','41038Axilesoft.ACGMediaPlayer','46928bounde.EclipseManager','4DF9E0F8.Netflix','64885BlueEdge.OneCalendar','7EE7776C.LinkedInforWindows','828B5831.HiddenCityMysteryofShadows','89006A2E.AutodeskSketchBook','9E2F88E3.Twitter','A278AB0D.DisneyMagicKingdoms','A278AB0D.MarchofEmpires','ActiproSoftwareLLC.562882FEEB491','AdobeSystemsIncorporated.AdobePhotoshopExpress','CAF9E577.Plex','D52A8D61.FarmVille2CountryEscape','D5EA27B7.Duolingo-LearnLanguagesforFree','DB6EA5DB.CyberLinkMediaSuiteEssentials','DolbyLaboratories.DolbyAccess','Drawboard.DrawboardPDF','Facebook.Facebook','flaregamesGmbH.RoyalRevolt2','GAMELOFTSA.Asphalt8Airborne','KeeperSecurityInc.Keeper','king.com.BubbleWitch3Saga','king.com.CandyCrushSodaSaga','king.com.CandyCrushSaga','PandoraMediaInc.29680B314EFC2','SpotifyAB.SpotifyMusic','WinZipComputing.WinZipUniversal','XINGAG.XING','2FE3CB00.PicsArt-PhotoStudio','613EBCEA.PolarrPhotoEditorAcademicEdition','6Wunderkinder.Wunderlist','ClearChannelRadioDigital.iHeartRadio','Fitbit.FitbitCoach','Flipboard.Flipboard','NORDCURRENT.COOKINGFEVER','Playtika.CaesarsSlotsFreeCasino','ShazamEntertainmentLtd.Shazam','SlingTVLLC.SlingTV','TheNewYorkTimes.NYTCrossword','ThumbmunkeysLtd.PhototasticCollage','TuneIn.TuneInRadio','Microsoft.Advertising.Xaml')) {
    Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object DisplayName -EQ $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# Prevent app reinstall
$cdmPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
mk $cdmPath
foreach ($k in @('ContentDeliveryAllowed','FeatureManagementEnabled','OemPreInstalledAppsEnabled','PreInstalledAppsEnabled','PreInstalledAppsEverEnabled','SilentInstalledAppsEnabled','SubscribedContent-314559Enabled','SubscribedContent-338387Enabled','SubscribedContent-338388Enabled','SubscribedContent-338389Enabled','SubscribedContent-338393Enabled','SubscribedContentEnabled','SystemPaneSuggestionsEnabled')) { sp $cdmPath $k DWord 0 }
mk 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore'; sp 'HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore' 'AutoDownload' DWord 2
mk 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsConsumerFeatures' DWord 1

# Disable optional features
Disable-WindowsOptionalFeature -Online -FeatureName 'WindowsMediaPlayer' -NoRestart -WarningAction SilentlyContinue | Out-Null
Disable-WindowsOptionalFeature -Online -FeatureName "Internet-Explorer-Optional-$env:PROCESSOR_ARCHITECTURE" -NoRestart -WarningAction SilentlyContinue | Out-Null
Disable-WindowsOptionalFeature -Online -FeatureName 'WorkFolders-Client' -NoRestart -WarningAction SilentlyContinue | Out-Null
Disable-WindowsOptionalFeature -Online -FeatureName 'Printing-PrintToPDFServices-Features' -NoRestart -WarningAction SilentlyContinue | Out-Null
Disable-WindowsOptionalFeature -Online -FeatureName 'Printing-XPSServices-Features' -NoRestart -WarningAction SilentlyContinue | Out-Null
Remove-Printer -Name 'Fax' -ErrorAction SilentlyContinue

# Xbox/GameDVR
sp 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled' DWord 0
mk 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR'; sp 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' 'AllowGameDVR' DWord 0

# Disable services
foreach ($svc in @('DiagTrack','diagnosticshub.standardcollector.service','dmwappushservice','WMPNetworkSvc','WSearch')) {
    sc.exe stop $svc 2>$null; sc.exe config $svc start= disabled 2>$null
}

# Disable scheduled tasks (telemetry/bloat)
foreach ($t in @('Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser','Microsoft\Windows\Application Experience\ProgramDataUpdater','Microsoft\Windows\Application Experience\StartupAppTask','Microsoft\Windows\Customer Experience Improvement Program\Consolidator','Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask','Microsoft\Windows\Customer Experience Improvement Program\UsbCeip','Microsoft\Windows\Customer Experience Improvement Program\Uploader','Microsoft\Windows\Shell\FamilySafetyUpload','Microsoft\Office\OfficeTelemetryAgentLogOn','Microsoft\Office\OfficeTelemetryAgentFallBack','Microsoft\Office\Office 15 Subscription Heartbeat','Microsoft\Windows\Autochk\Proxy','Microsoft\Windows\CloudExperienceHost\CreateObjectTask','Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector','Microsoft\Windows\DiskFootprint\Diagnostics','Microsoft\Windows\FileHistory\File History (maintenance mode)','Microsoft\Windows\Maintenance\WinSAT','Microsoft\Windows\NetTrace\GatherNetworkInfo','Microsoft\Windows\PI\Sqm-Tasks','Microsoft\Windows\Windows Error Reporting\QueueReporting','Microsoft\Windows\WindowsUpdate\Automatic App Update')) {
    schtasks /Change /TN $t /Disable 2>$null
}

# Telemetry registry
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v PreventDeviceMetadataFromNetwork /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v DontOfferThroughWUAU /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v CEIPEnable /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v AITEnable /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v DisableUAR /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v Start /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\SQMLogger" /v Start /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v EnableWebContentEvaluation /t REG_DWORD /d 0 /f
reg add "HKCU\Control Panel\International\User Profile" /v HttpAcceptLanguageOptOut /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" /v value /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" /v value /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v UxOption /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v DODownloadMode /t REG_DWORD /d 0 /f

# Windows hardening (ASR rules, lsass, DLL hijack, IPv6 disable)
$asrRules = @('D4F940AB-401B-4EFC-AADC-AD5F3C50688A','75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84','92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B','3B576869-A4EC-4529-8536-B80A7769E899','5BEB7EFE-FD9A-4556-801D-275E5FFC04CC','BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550','D3E037E1-3EB8-44C8-A917-57927947596D','01443614-cd74-433a-b99e-2ecdc07bfc25','C1DB55AB-C21A-4637-BB3F-A12568109D35','9E6C4E1F-7D60-472F-BA1A-A39EF669E4B2','B2B3F03D-6A65-4F7B-A9C7-1C7EF74A9BA4')
foreach ($id in $asrRules) { Add-MpPreference -AttackSurfaceReductionRules_Ids $id -AttackSurfaceReductionRules_Actions Enabled -ErrorAction SilentlyContinue }
Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction SilentlyContinue
Set-MpPreference -MAPSReporting Advanced -ErrorAction SilentlyContinue
Set-MpPreference -SubmitSamplesConsent Always -ErrorAction SilentlyContinue
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/freeload101/SCRIPTS/master/Windows_Batch/ProcessMitigation.xml" -OutFile "ProcessMitigation.xml" -ErrorAction SilentlyContinue
if (Test-Path "ProcessMitigation.xml") { Set-ProcessMitigation -PolicyFilePath "ProcessMitigation.xml"; Remove-Item "ProcessMitigation.xml" -Force }

# lsass hardening
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\LSASS.exe" /v AuditLevel /t REG_DWORD /d 8 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RunAsPPL /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v DisableRestrictedAdmin /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v DisableRestrictedAdminOutboundCreds /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v UseLogonCredential /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v Negotiate /t REG_DWORD /d 0 /f

# DLL hijack prevention
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v CWDIllegalInDllSearch /t REG_DWORD /d 0x2 /f

# Disable IPv6
reg add "HKLM\SYSTEM\CurrentControlSet\services\tcpip6\parameters" /v DisabledComponents /t REG_DWORD /d 0xFF /f

# Adobe Reader hardening
reg add "HKLM\Software\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown" /v iFileAttachmentPerms /t REG_DWORD /d 1 /f

# Office macro hardening
foreach ($ver in @('12.0','14.0','15.0','16.0')) {
    foreach ($app in @('Publisher','Word')) { reg add "HKCU\Software\Policies\Microsoft\Office\$ver\$app\Security" /v vbawarnings /t REG_DWORD /d 4 /f }
}
foreach ($ver in @('15.0','16.0')) {
    foreach ($app in @('Word','Excel','PowerPoint')) { reg add "HKCU\Software\Policies\Microsoft\Office\$ver\$app\Security" /v blockcontentexecutionfrominternet /t REG_DWORD /d 1 /f }
    reg add "HKCU\Software\Policies\Microsoft\Office\$ver\Outlook\Security" /v markinternalasunsafe /t REG_DWORD /d 0 /f
}
foreach ($ver in @('14.0','15.0','16.0')) {
    foreach ($sub in @('','WordMail')) { reg add "HKCU\Software\Microsoft\Office\$ver\Word\Options\$sub" /v DontUpdateLinks /t REG_DWORD /d 1 /f }
}

# Unpin taskbar
sp 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband' 'Favorites' Binary ([byte[]](255))
Remove-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband' -Name 'FavoritesResolve' -ErrorAction SilentlyContinue

# Win11 context menu (TrustedInstaller hack)
sc.exe stop TrustedInstaller 2>$null
sc.exe config TrustedInstaller binPath= 'cmd /c reg add "HKCU\Software\Classes\CLSID{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve' 2>$null
sc.exe start TrustedInstaller 2>$null; Start-Sleep -s 2; sc.exe stop TrustedInstaller 2>$null
sc.exe config TrustedInstaller binPath= 'cmd /c reg add "HKLM\Software\Classes\CLSID{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve' 2>$null
sc.exe start TrustedInstaller 2>$null; Start-Sleep -s 2; sc.exe stop TrustedInstaller 2>$null
sc.exe config TrustedInstaller binPath= 'C:\Windows\servicing\TrustedInstaller.exe' 2>$null

#endregion

Write-Host "[+] All done! Reboot recommended." -ForegroundColor Green
