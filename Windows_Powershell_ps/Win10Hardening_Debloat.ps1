##########
# Note this script is for personal use ... you may find that this script disables things you use ... Edge,Defendfer ,System restore etc .. use at your own risk 
# UPDATED FOR WIN 11 WIP
# Win10 / WinServer2016 Initial Setup Script
# updated 2021 for https://github.com/freeload101 - rmccurdy.com
# basicly  keeping SMB1 stuff but RemoveW10Bloat.bat , remove-default-apps.ps1 ,Win10Hardening.ps1 and windows_hardening.cmd all in one with settings I like
# some dupes here but whatever
#########

# disable signin with google chrome prompt ... 

# Check if the Chrome policies key exists
$chromePoliciesPath = "HKLM:\SOFTWARE\Policies\Google\Chrome"
if (-Not (Test-Path $chromePoliciesPath)) {
    # Create the Chrome policies key because it doesn't exist
    New-Item -Path $chromePoliciesPath -Force
}

# Set the BrowserSignin policy to 0 to disable browser sign-in
Set-ItemProperty -Path $chromePoliciesPath -Name "BrowserSignin" -Value 0



# disable system restore
Disable-ComputerRestore -Drive "C:\"


##   startup boost => Disabled https://github.com/RedAndBlueEraser/windows-10-enhance-2/blob/master/windows-10-enhance-privacy-and-control.ps1 
reg add "HKCU\SOFTWARE\Policies\Microsoft\Edge" /v StartupBoostEnabled /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Policies\Microsoft\Edge\Recommended" /v StartupBoostEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v StartupBoostEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge\Recommended" /v StartupBoostEnabled /t REG_DWORD /d 0 /f


## start/run history
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d 0x0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs"  /t REG_DWORD /d 0x0 /f


## NEW STUFF 2021 BECAUSE.... WINDOWS UPDATES LIKES TO RE ENABLE STUFF YOU DISABLED AND ADD EVEN MORE CRAP YOU DON'T WANT
# Disable "News and Interests" ... the weather BS in the start menu ..
Reg Add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Feeds" /T REG_DWORD /V "ShellFeedsTaskbarViewMode" /D 2 /F

# Disable "Meet Now" because it's not nuff to disable Skype ...
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideSCAMeetNow" -Value 1

# Default preset
$tweaks = @(
	### Require administrator privileges ###
	"RequireAdmin",

	### Privacy Tweaks ###
	"DisableTelemetry",             # "EnableTelemetry",
	"DisableWiFiSense",             # "EnableWiFiSense",   
    "DisableSmartScreen",
	"DisableWebSearch",             # "EnableWebSearch",
	"DisableAppSuggestions",        # "EnableAppSuggestions",
	"DisableActivityHistory",       # "EnableActivityHistory",
	"DisableBackgroundApps",        # "EnableBackgroundApps",
	"DisableLocationTracking",      # "EnableLocationTracking",
	"DisableMapUpdates",            # "EnableMapUpdates",
	"DisableFeedback",              # "EnableFeedback",
	"DisableTailoredExperiences",   # "EnableTailoredExperiences",
	"DisableAdvertisingID",         # "EnableAdvertisingID",
	"DisableCortana",               # "EnableCortana",
	"DisableErrorReporting",        # "EnableErrorReporting",
	                                # "SetP2PUpdateLocal",          
                                    # "SetP2PUpdateInternet",
	"DisableDiagTrack",             # "EnableDiagTrack",
	"DisableWAPPush",               # "EnableWAPPush",

	### Security Tweaks ###
	                                # "SetUACLow",                   
    #  "SetUACHigh",
	# "EnableSharingMappedDrives",  # "DisableSharingMappedDrives",
	#"DisableAdminShares",           # "EnableAdminShares",
	#  "DisableSMB1",                # "EnableSMB1", # I USE SMBV1 SO YOU CAN DISABLE IF YOU WANT
	#  "DisableSMBServer",           # "EnableSMBServer", # I USE SMBV1 SO YOU CAN DISABLE IF YOU WANT
	# "DisableLLMNR",               # "EnableLLMNR", # I USE SMBV1 SO YOU CAN DISABLE IF YOU WANT
	"SetCurrentNetworkPrivate",     # "SetCurrentNetworkPublic",
	# "SetUnknownNetworksPrivate",  # "SetUnknownNetworksPublic",
	# "DisableNetDevicesAutoInst",  # "EnableNetDevicesAutoInst",
	# "EnableCtrldFolderAccess",    # "DisableCtrldFolderAccess",
	                                # "DisableFirewall",              
    #"EnableFirewall",
	"DisableDefender",             # "EnableDefender",
	"DisableDefenderCloud",        # "EnableDefenderCloud",
	#"EnableF8BootMenu",             # "DisableF8BootMenu", This breaks disk crypto stuff so keep it disabled
	"SetDEPOptOut",                 # "SetDEPOptIn",
	                                # "EnableCIMemoryIntegrity",   
    "DisableCIMemoryIntegrity",
	"DisableScriptHost",            # "EnableScriptHost",
	"EnableDotNetStrongCrypto",     # "DisableDotNetStrongCrypto",
	"EnableMeltdownCompatFlag"      # "DisableMeltdownCompatFlag",

	### Service Tweaks ###
	# "DisableUpdateMSRT",          # "EnableUpdateMSRT",
	# "DisableUpdateDriver",        # "EnableUpdateDriver",
	"DisableUpdateRestart",         # "EnableUpdateRestart",
	"DisableHomeGroups",            # "EnableHomeGroups",
	"DisableSharedExperiences",     # "EnableSharedExperiences",
	"DisableRemoteAssistance",      # "EnableRemoteAssistance",
	"EnableRemoteDesktop",          # "DisableRemoteDesktop",
	"DisableAutoplay",              # "EnableAutoplay",
	"DisableAutorun",               # "EnableAutorun",
	# "EnableStorageSense",         # "DisableStorageSense",
	 "DisableDefragmentation",     # "EnableDefragmentation",
	 "DisableSuperfetch",          # "EnableSuperfetch",
	 "DisableIndexing",            # "EnableIndexing",
	# "SetBIOSTimeUTC",             # "SetBIOSTimeLocal",
	# "EnableHibernation",          # "DisableHibernation",
	# "DisableSleepButton",         # "EnableSleepButton",
	# "DisableSleepTimeout",        # "EnableSleepTimeout",
	# "DisableFastStartup",         # "EnableFastStartup",

	### UI Tweaks ###
	"DisableActionCenter",          # "EnableActionCenter",
	"DisableLockScreen",            # "EnableLockScreen",
	"DisableLockScreenRS1",         # "EnableLockScreenRS1",
	"HideNetworkFromLockScreen",    # "ShowNetworkOnLockScreen",
	"HideShutdownFromLockScreen",   # "ShowShutdownOnLockScreen",
	"DisableStickyKeys",            # "EnableStickyKeys",
	# hangs windows 11 "ShowTaskManagerDetails"        # "HideTaskManagerDetails",
	"ShowFileOperationsDetails",    # "HideFileOperationsDetails",
	"EnableFileDeleteConfirm",      # "DisableFileDeleteConfirm",
	"HideTaskbarSearch",            # "ShowTaskbarSearchIcon",      # "ShowTaskbarSearchBox",
	"HideTaskView",                 # "ShowTaskView",
	"ShowSmallTaskbarIcons",        # "ShowLargeTaskbarIcons",
	"SetTaskbarCombineWhenFull",    # "SetTaskbarCombineNever",     # "SetTaskbarCombineAlways",
	"HideTaskbarPeopleIcon",        # "ShowTaskbarPeopleIcon",
	"ShowTrayIcons",                # "HideTrayIcons",
	"DisableSearchAppInStore",      # "EnableSearchAppInStore",
	"DisableNewAppPrompt",          # "EnableNewAppPrompt",
	"SetControlPanelSmallIcons",    # "SetControlPanelLargeIcons",  # "SetControlPanelCategories",
	"SetVisualFXPerformance",       # "SetVisualFXAppearance",
	# "AddENKeyboard",              # "RemoveENKeyboard",
	# "EnableNumlock",              # "DisableNumlock",

	### Explorer UI Tweaks ###
	"ShowKnownExtensions",          # "HideKnownExtensions",
	"ShowHiddenFiles",              # "HideHiddenFiles",
	"HideSyncNotifications"         # "ShowSyncNotifications",
	"HideRecentShortcuts",          # "ShowRecentShortcuts",
	"SetExplorerThisPC",            # "SetExplorerQuickAccess",
	"ShowThisPCOnDesktop",          # "HideThisPCFromDesktop",
	# "ShowUserFolderOnDesktop",    # "HideUserFolderFromDesktop",
	"HideDesktopFromThisPC",        # "ShowDesktopInThisPC",
	# "HideDesktopFromExplorer",    # "ShowDesktopInExplorer",
	"HideDocumentsFromThisPC",      # "ShowDocumentsInThisPC",
	# "HideDocumentsFromExplorer",  # "ShowDocumentsInExplorer",
	"HideDownloadsFromThisPC",      # "ShowDownloadsInThisPC",
	# "HideDownloadsFromExplorer",  # "ShowDownloadsInExplorer",
	"HideMusicFromThisPC",          # "ShowMusicInThisPC",
	# "HideMusicFromExplorer",      # "ShowMusicInExplorer",
	"HidePicturesFromThisPC",       # "ShowPicturesInThisPC",
	"HidePicturesFromExplorer",   # "ShowPicturesInExplorer",
	"HideVideosFromThisPC",         # "ShowVideosInThisPC",
	"HideVideosFromExplorer",     # "ShowVideosInExplorer",
	"Hide3DObjectsFromThisPC",      # "Show3DObjectsInThisPC",
	"Hide3DObjectsFromExplorer",  # "Show3DObjectsInExplorer",
	# "DisableThumbnails",          # "EnableThumbnails",
	"DisableThumbsDB",              # "EnableThumbsDB",

	### Application Tweaks ###
	"DisableOneDrive",              # "EnableOneDrive",
	"UninstallOneDrive",            # "InstallOneDrive",
	"UninstallMsftBloat",           # "InstallMsftBloat",
	"UninstallThirdPartyBloat",     # "InstallThirdPartyBloat",
	"UninstallWindowsStore",        # "InstallWindowsStore",
	"DisableXboxFeatures",          # "EnableXboxFeatures",
	"DisableAdobeFlash",            # "EnableAdobeFlash",
	"UninstallMediaPlayer",         # "InstallMediaPlayer",
	"UninstallInternetExplorer",    # "InstallInternetExplorer",
	"UninstallWorkFolders",       # "InstallWorkFolders",
	# "InstallLinuxSubsystem",      # "UninstallLinuxSubsystem",
	                                # "InstallHyperV",                
    #"UninstallHyperV",				# not messing with this ..
	"SetPhotoViewerAssociation",    # "UnsetPhotoViewerAssociation",
	"RemovePhotoViewerOpenWith",       # "RemovePhotoViewerOpenWith",
	"UninstallPDFPrinter",          # "InstallPDFPrinter",
	"UninstallXPSPrinter",          # "InstallXPSPrinter",
	"RemoveFaxPrinter",             # "AddFaxPrinter",

	### Server Specific Tweaks ###
	# "HideServerManagerOnLogin",   # "ShowServerManagerOnLogin",
	# "DisableShutdownTracker",     # "EnableShutdownTracker",
	# "DisablePasswordPolicy",      # "EnablePasswordPolicy",
	# "DisableCtrlAltDelLogin",     # "EnableCtrlAltDelLogin",
	# "DisableIEEnhancedSecurity",  # "EnableIEEnhancedSecurity",
	# "EnableAudio",                # "DisableAudio",

	### Unpinning ###
	 "UnpinStartMenuTiles",
	 "UnpinTaskbarIcons",

	### RemoveW10Bloat  some dupes here etc ###
	"RemoveW10Bloat"
	
	### remove-default-apps.ps1 some dupes here etc  ###
	"remove_default_apps"
	
	### enable some the stuff from windows_hardening.cmd ###
	"windows_hardening"
	
	
	
	### Auxiliary Functions ###
	#"WaitForKey",
	#"Restart"
)



##########
# Privacy Tweaks
##########

# Disable Telemetry
# Note: This tweak may cause Enterprise edition to stop receiving Windows updates.
# Windows Update control panel will then show message "Your device is at risk because it's out of date and missing important security and quality updates. Let's get you back on track so Windows can run more securely. Select this button to get going".
# In such case, enable telemetry, run Windows update and then disable telemetry again. 
Function DisableTelemetry {
	Write-Output "Disabling Telemetry..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy" | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" | Out-Null
}

# Enable Telemetry
Function EnableTelemetry {
	Write-Output "Enabling Telemetry..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 3
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 3
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -ErrorAction SilentlyContinue
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" | Out-Null
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Application Experience\ProgramDataUpdater" | Out-Null
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Autochk\Proxy" | Out-Null
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" | Out-Null
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" | Out-Null
	Enable-ScheduledTask -TaskName "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" | Out-Null
}

# Disable Wi-Fi Sense
Function DisableWiFiSense {
	Write-Output "Disabling Wi-Fi Sense..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -Type Dword -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "WiFISenseAllowed" -Type Dword -Value 0
}

# Enable Wi-Fi Sense
Function EnableWiFiSense {
	Write-Output "Enabling Wi-Fi Sense..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" -Name "Value" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" -Name "Value" -Type DWord -Value 1
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "AutoConnectAllowedOEM" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config" -Name "WiFISenseAllowed" -ErrorAction SilentlyContinue
}

# Disable SmartScreen Filter
Function DisableSmartScreen {
	Write-Output "Disabling SmartScreen Filter..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" -Name "EnabledV9" -Type DWord -Value 0
}

# Enable SmartScreen Filter
Function EnableSmartScreen {
	Write-Output "Enabling SmartScreen Filter..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter" -Name "EnabledV9" -ErrorAction SilentlyContinue
}

# Disable Web Search in Start Menu
Function DisableWebSearch {
	Write-Output "Disabling Bing Search in Start Menu..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1
}

# Enable Web Search in Start Menu
Function EnableWebSearch {
	Write-Output "Enabling Bing Search in Start Menu..."
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -ErrorAction SilentlyContinue
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 1
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -ErrorAction SilentlyContinue
}

# Disable Application suggestions and automatic installation
Function DisableAppSuggestions {
	Write-Output "Disabling Application suggestions..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1
}

# Enable Application suggestions and automatic installation
Function EnableAppSuggestions {
	Write-Output "Enabling Application suggestions..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 1
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -ErrorAction SilentlyContinue
}

# Disable Activity History feed in Task View - Note: The checkbox "Let Windows collect my activities from this PC" remains checked even when the function is disabled
Function DisableActivityHistory {
	Write-Output "Disabling Activity History..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type DWord -Value 0
}

# Enable Activity History feed in Task View
Function EnableActivityHistory {
	Write-Output "Enabling Activity History..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -ErrorAction SilentlyContinue
}

# Disable Background application access - ie. if apps can download or update when they aren't used - Cortana is excluded as its inclusion breaks start menu search
Function DisableBackgroundApps {
	Write-Output "Disabling Background application access..."
	Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Exclude "Microsoft.Windows.Cortana*" | ForEach {
		Set-ItemProperty -Path $_.PsPath -Name "Disabled" -Type DWord -Value 1
		Set-ItemProperty -Path $_.PsPath -Name "DisabledByUser" -Type DWord -Value 1
	}
}

# Enable Background application access
Function EnableBackgroundApps {
	Write-Output "Enabling Background application access..."
	Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" | ForEach {
		Remove-ItemProperty -Path $_.PsPath -Name "Disabled" -ErrorAction SilentlyContinue
		Remove-ItemProperty -Path $_.PsPath -Name "DisabledByUser" -ErrorAction SilentlyContinue
	}
}

# Disable Location Tracking
Function DisableLocationTracking {
	Write-Output "Disabling Location Tracking..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Deny"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 0
}

# Enable Location Tracking
Function EnableLocationTracking {
	Write-Output "Enabling Location Tracking..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Allow"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" -Name "Status" -Type DWord -Value 1
}

# Disable automatic Maps updates
Function DisableMapUpdates {
	Write-Output "Disabling automatic Maps updates..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -Type DWord -Value 0
}

# Enable automatic Maps updates
Function EnableMapUpdates {
	Write-Output "Enable automatic Maps updates..."
	Remove-ItemProperty -Path "HKLM:\SYSTEM\Maps" -Name "AutoUpdateEnabled" -ErrorAction SilentlyContinue
}

# Disable Feedback
Function DisableFeedback {
	Write-Output "Disabling Feedback..."
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null
}

# Enable Feedback
Function EnableFeedback {
	Write-Output "Enabling Feedback..."
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -ErrorAction SilentlyContinue
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClient" -ErrorAction SilentlyContinue | Out-Null
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload" -ErrorAction SilentlyContinue | Out-Null
}

# Disable Tailored Experiences
Function DisableTailoredExperiences {
	Write-Output "Disabling Tailored Experiences..."
	If (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
		New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -Type DWord -Value 1
}

# Enable Tailored Experiences
Function EnableTailoredExperiences {
	Write-Output "Enabling Tailored Experiences..."
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableTailoredExperiencesWithDiagnosticData" -ErrorAction SilentlyContinue
}

# Disable Advertising ID
Function DisableAdvertisingID {
	Write-Output "Disabling Advertising ID..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Type DWord -Value 1
}

# Enable Advertising ID
Function EnableAdvertisingID {
	Write-Output "Enabling Advertising ID..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -ErrorAction SilentlyContinue
}

# Disable Cortana
Function DisableCortana {
	Write-Output "Disabling Cortana..."
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Type DWord -Value 0
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 1
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0
}

# Enable Cortana
Function EnableCortana {
	Write-Output "Enabling Cortana..."
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -ErrorAction SilentlyContinue
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Type DWord -Value 0
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -ErrorAction SilentlyContinue
}

# Disable Error reporting
Function DisableErrorReporting {
	Write-Output "Disabling Error reporting..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Type DWord -Value 1
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting" | Out-Null
}

# Enable Error reporting
Function EnableErrorReporting {
	Write-Output "Enabling Error reporting..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -ErrorAction SilentlyContinue
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Windows Error Reporting\QueueReporting" | Out-Null
}

# Restrict Windows Update P2P only to local network - Needed only for 1507 as local P2P is the default since 1511
Function SetP2PUpdateLocal {
	Write-Output "Restricting Windows Update P2P only to local network..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Type DWord -Value 1
}

# Unrestrict Windows Update P2P
Function SetP2PUpdateInternet {
	Write-Output "Unrestricting Windows Update P2P to internet..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -ErrorAction SilentlyContinue
}

# Stop and disable Diagnostics Tracking Service
Function DisableDiagTrack {
	Write-Output "Stopping and disabling Diagnostics Tracking Service..."
	Stop-Service "DiagTrack" -WarningAction SilentlyContinue
	Set-Service "DiagTrack" -StartupType Disabled
}

# Enable and start Diagnostics Tracking Service
Function EnableDiagTrack {
	Write-Output "Enabling and starting Diagnostics Tracking Service..."
	Set-Service "DiagTrack" -StartupType Automatic
	Start-Service "DiagTrack" -WarningAction SilentlyContinue
}

# Stop and disable WAP Push Service
Function DisableWAPPush {
	Write-Output "Stopping and disabling WAP Push Service..."
	Stop-Service "dmwappushservice" -WarningAction SilentlyContinue
	Set-Service "dmwappushservice" -StartupType Disabled
}

# Enable and start WAP Push Service
Function EnableWAPPush {
	Write-Output "Enabling and starting WAP Push Service..."
	Set-Service "dmwappushservice" -StartupType Automatic
	Start-Service "dmwappushservice" -WarningAction SilentlyContinue
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\dmwappushservice" -Name "DelayedAutoStart" -Type DWord -Value 1
}



##########
# Security Tweaks
##########

# Lower UAC level (disabling it completely would break apps)
Function SetUACLow {
	Write-Output "Lowering UAC level..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 0
}

# Raise UAC level
Function SetUACHigh {
	Write-Output "Raising UAC level..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Type DWord -Value 5
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Type DWord -Value 1
}

# Enable sharing mapped drives between users
Function EnableSharingMappedDrives {
	Write-Output "Enabling sharing mapped drives between users..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLinkedConnections" -Type DWord -Value 1
}

# Disable sharing mapped drives between users
Function DisableSharingMappedDrives {
	Write-Output "Disabling sharing mapped drives between users..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLinkedConnections" -ErrorAction SilentlyContinue
}

# Disable implicit administrative shares
Function DisableAdminShares {
	Write-Output "Disabling implicit administrative shares..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareWks" -Type DWord -Value 0
}

# Enable implicit administrative shares
Function EnableAdminShares {
	Write-Output "Enabling implicit administrative shares..."
	Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareWks" -ErrorAction SilentlyContinue
}

# Disable obsolete SMB 1.0 protocol - Disabled by default since 1709
Function DisableSMB1 {
	Write-Output "Disabling SMB 1.0 protocol..."
	Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
}

# Enable obsolete SMB 1.0 protocol - Disabled by default since 1709
Function EnableSMB1 {
	Write-Output "Enabling SMB 1.0 protocol..."
	Set-SmbServerConfiguration -EnableSMB1Protocol $true -Force
}

# Disable SMB Server - Completely disables file and printer sharing, but leaves the system able to connect to another SMB server as a client
Function DisableSMBServer {
	Write-Output "Disabling SMB Server..."
	Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
	Set-SmbServerConfiguration -EnableSMB2Protocol $false -Force
}

# Enable SMB Server
Function EnableSMBServer {
	Write-Output "Enabling SMB Server..."
	Set-SmbServerConfiguration -EnableSMB2Protocol $true -Force
}

# Disable Link-Local Multicast Name Resolution (LLMNR) protocol
Function DisableLLMNR {
	Write-Output "Disabling LLMNR..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -Type DWord -Value 0
}

# Enable Link-Local Multicast Name Resolution (LLMNR) protocol
Function EnableLLMNR {
	Write-Output "Enabling LLMNR..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -ErrorAction SilentlyContinue
}

# Set current network profile to private (allow file sharing, device discovery, etc.)
Function SetCurrentNetworkPrivate {
	Write-Output "Setting current network profile to private..."
	Set-NetConnectionProfile -NetworkCategory Private
}

# Set current network profile to public (deny file sharing, device discovery, etc.)
Function SetCurrentNetworkPublic {
	Write-Output "Setting current network profile to public..."
	Set-NetConnectionProfile -NetworkCategory Public
}

# Set unknown networks profile to private (allow file sharing, device discovery, etc.)
Function SetUnknownNetworksPrivate {
	Write-Output "Setting unknown networks profile to private..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24" -Name "Category" -Type DWord -Value 1
}

# Set unknown networks profile to public (deny file sharing, device discovery, etc.)
Function SetUnknownNetworksPublic {
	Write-Output "Setting unknown networks profile to public..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\NetworkList\Signatures\010103000F0000F0010000000F0000F0C967A3643C3AD745950DA7859209176EF5B87C875FA20DF21951640E807D7C24" -Name "Category" -ErrorAction SilentlyContinue
}

# Disable automatic installation of network devices
Function DisableNetDevicesAutoInst {
	Write-Output "Disabling automatic installation of network devices..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Name "AutoSetup" -Type DWord -Value 0
}

# Enable automatic installation of network devices
Function EnableNetDevicesAutoInst {
	Write-Output "Enabling automatic installation of network devices..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\NcdAutoSetup\Private" -Name "AutoSetup" -ErrorAction SilentlyContinue
}

# Enable Controlled Folder Access (Defender Exploit Guard feature) - Applicable to 1709 or newer, requires Windows Defender to be enabled
Function EnableCtrldFolderAccess {
	Write-Output "Enabling Controlled Folder Access..."
	Set-MpPreference -EnableControlledFolderAccess Enabled
}

# Disable Controlled Folder Access (Defender Exploit Guard feature) - Applicable to 1709 or newer, requires Windows Defender to be enabled
Function DisableCtrldFolderAccess {
	Write-Output "Disabling Controlled Folder Access..."
	Set-MpPreference -EnableControlledFolderAccess Disabled
}

# Disable Firewall
Function DisableFirewall {
	Write-Output "Disabling Firewall..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" -Name "EnableFirewall" -Type DWord -Value 0
}

# Enable Firewall
Function EnableFirewall {
	Write-Output "Enabling Firewall..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile" -Name "EnableFirewall" -ErrorAction SilentlyContinue
}

# Disable Windows Defender
Function DisableDefender {
	Write-Output "Disabling Windows Defender..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Type DWord -Value 1
	If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsDefender" -ErrorAction SilentlyContinue
	} ElseIf ([System.Environment]::OSVersion.Version.Build -ge 15063) {
		Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -ErrorAction SilentlyContinue
	}
}

# Enable Windows Defender
Function EnableDefender {
	Write-Output "Enabling Windows Defender..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -ErrorAction SilentlyContinue
	If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsDefender" -Type ExpandString -Value "`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`""
	} ElseIf ([System.Environment]::OSVersion.Version.Build -ge 15063) {
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -Type ExpandString -Value "`"%ProgramFiles%\Windows Defender\MSASCuiL.exe`""
	}
}

# Disable Windows Defender Cloud
Function DisableDefenderCloud {
	Write-Output "Disabling Windows Defender Cloud..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SpynetReporting" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SubmitSamplesConsent" -Type DWord -Value 2
}

# Enable Windows Defender Cloud
Function EnableDefenderCloud {
	Write-Output "Enabling Windows Defender Cloud..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SpynetReporting" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" -Name "SubmitSamplesConsent" -ErrorAction SilentlyContinue
}

# Enable F8 boot menu options
Function EnableF8BootMenu {
	Write-Output "Enabling F8 boot menu options..."
	bcdedit /set `{current`} bootmenupolicy Legacy | Out-Null
}

# Disable F8 boot menu options
Function DisableF8BootMenu {
	Write-Output "Disabling F8 boot menu options..."
	bcdedit /set `{current`} bootmenupolicy Standard | Out-Null
}

# Set Data Execution Prevention (DEP) policy to OptOut
Function SetDEPOptOut {
	Write-Output "Setting Data Execution Prevention (DEP) policy to OptOut..."
	bcdedit /set `{current`} nx OptOut | Out-Null
}

# Set Data Execution Prevention (DEP) policy to OptIn
Function SetDEPOptIn {
	Write-Output "Setting Data Execution Prevention (DEP) policy to OptIn..."
	bcdedit /set `{current`} nx OptIn | Out-Null
}

# Enable Core Isolation Memory Integrity - Part of Windows Defender System Guard virtualization-based security - Supported from 1803
Function EnableCIMemoryIntegrity {
	Write-Output "Enabling Core Isolation Memory Integrity..."
	If (!(Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity")) {
		New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Type DWord -Value 1
}

# Disable Core Isolation Memory Integrity - 
Function DisableCIMemoryIntegrity {
	Write-Output "Disabling Core Isolation Memory Integrity..."
	Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -ErrorAction SilentlyContinue
}

# Disable Windows Script Host (execution of *.vbs scripts and alike)
Function DisableScriptHost {
	Write-Output "Disabling Windows Script Host..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings" -Name "Enabled" -Type DWord -Value 0
}

# Enable Windows Script Host
Function EnableScriptHost {
	Write-Output "Enabling Windows Script Host..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Script Host\Settings" -Name "Enabled" -ErrorAction SilentlyContinue
}

# Enable strong cryptography for .NET Framework (version 4 and above)
# https://stackoverflow.com/questions/36265534/invoke-webrequest-ssl-fails
Function EnableDotNetStrongCrypto {
	Write-output "Enabling .NET strong cryptography..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -Type DWord -Value 1
}

# Disable strong cryptography for .NET Framework (version 4 and above)
Function DisableDotNetStrongCrypto {
	Write-output "Disabling .NET strong cryptography..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319" -Name "SchUseStrongCrypto" -ErrorAction SilentlyContinue
}

# Enable Meltdown (CVE-2017-5754) compatibility flag - Required for January 2018 and all subsequent Windows updates
# This flag is normally automatically enabled by compatible antivirus software (such as Windows Defender).
# Use the tweak only if you have confirmed that your AV is compatible but unable to set the flag automatically or if you don't use any AV at all.
# See https://support.microsoft.com/en-us/help/4072699/january-3-2018-windows-security-updates-and-antivirus-software for details.
Function EnableMeltdownCompatFlag {
	Write-Output "Enabling Meltdown (CVE-2017-5754) compatibility flag..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat" -Name "cadca5fe-87d3-4b96-b7fb-a231484277cc" -Type DWord -Value 0
}

# Disable Meltdown (CVE-2017-5754) compatibility flag
Function DisableMeltdownCompatFlag {
	Write-Output "Disabling Meltdown (CVE-2017-5754) compatibility flag..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\QualityCompat" -Name "cadca5fe-87d3-4b96-b7fb-a231484277cc" -ErrorAction SilentlyContinue
}



##########
# Service Tweaks
##########

# Disable offering of Malicious Software Removal Tool through Windows Update
Function DisableUpdateMSRT {
	Write-Output "Disabling Malicious Software Removal Tool offering..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" -Name "DontOfferThroughWUAU" -Type DWord -Value 1
}

# Enable offering of Malicious Software Removal Tool through Windows Update
Function EnableUpdateMSRT {
	Write-Output "Enabling Malicious Software Removal Tool offering..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MRT" -Name "DontOfferThroughWUAU" -ErrorAction SilentlyContinue
}

# Disable offering of drivers through Windows Update
# Note: This doesn't work properly if you use a driver intended for another hardware model. E.g. Intel I219-V on WinServer works only with I219-LM driver.
# Therefore Windows update will repeatedly try and fail to install I219-V driver indefinitely even if you use the tweak.
Function DisableUpdateDriver {
	Write-Output "Disabling driver offering through Windows Update..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -Type DWord -Value 1
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontPromptForWindowsUpdate" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontSearchWindowsUpdate" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DriverUpdateWizardWuSearchEnabled" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -Type DWord -Value 1
}

# Enable offering of drivers through Windows Update
Function EnableUpdateDriver {
	Write-Output "Enabling driver offering through Windows Update..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontPromptForWindowsUpdate" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontSearchWindowsUpdate" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DriverUpdateWizardWuSearchEnabled" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -ErrorAction SilentlyContinue
}

# Disable Windows Update automatic restart
# Note: This doesn't disable the need for the restart but rather tries to ensure that the restart doesn't happen in the least expected moment. Allow the machine to restart as soon as possible anyway.
Function DisableUpdateRestart {
	Write-Output "Disabling Windows Update automatic restart..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUPowerManagement" -Type DWord -Value 0
}

# Enable Windows Update automatic restart
Function EnableUpdateRestart {
	Write-Output "Enabling Windows Update automatic restart..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUPowerManagement" -ErrorAction SilentlyContinue
}

# Stop and disable Home Groups services - Not applicable to 1803 and newer or Server
Function DisableHomeGroups {
	Write-Output "Stopping and disabling Home Groups services..."
	Stop-Service "HomeGroupListener" -WarningAction SilentlyContinue
	Set-Service "HomeGroupListener" -StartupType Disabled
	Stop-Service "HomeGroupProvider" -WarningAction SilentlyContinue
	Set-Service "HomeGroupProvider" -StartupType Disabled
}

# Enable and start Home Groups services - Not applicable to 1803 and newer or Server
Function EnableHomeGroups {
	Write-Output "Starting and enabling Home Groups services..."
	Set-Service "HomeGroupListener" -StartupType Manual
	Set-Service "HomeGroupProvider" -StartupType Manual
	Start-Service "HomeGroupProvider" -WarningAction SilentlyContinue
}

# Disable Shared Experiences - Not applicable to Server
Function DisableSharedExperiences {
	Write-Output "Disabling Shared Experiences..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableCdp" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableMmx" -Type DWord -Value 0
}

# Enable Shared Experiences - Not applicable to Server
Function EnableSharedExperiences {
	Write-Output "Enabling Shared Experiences..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableCdp" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableMmx" -ErrorAction SilentlyContinue
}

# Disable Remote Assistance - Not applicable to Server (unless Remote Assistance is explicitly installed)
Function DisableRemoteAssistance {
	Write-Output "Disabling Remote Assistance..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0
}

# Enable Remote Assistance - Not applicable to Server (unless Remote Assistance is explicitly installed)
Function EnableRemoteAssistance {
	Write-Output "Enabling Remote Assistance..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 1
}

# Enable Remote Desktop w/o Network Level Authentication
Function EnableRemoteDesktop {
	Write-Output "Enabling Remote Desktop w/o Network Level Authentication..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Type DWord -Value 0
	Enable-NetFirewallRule -Name "RemoteDesktop*"
}

# Disable Remote Desktop
Function DisableRemoteDesktop {
	Write-Output "Disabling Remote Desktop..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Type DWord -Value 1
	Disable-NetFirewallRule -Name "RemoteDesktop*"
}

# Disable Autoplay
Function DisableAutoplay {
	Write-Output "Disabling Autoplay..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 1
}

# Enable Autoplay
Function EnableAutoplay {
	Write-Output "Enabling Autoplay..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Type DWord -Value 0
}

# Disable Autorun for all drives
Function DisableAutorun {
	Write-Output "Disabling Autorun for all drives..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -Type DWord -Value 255
}

# Enable Autorun for removable drives
Function EnableAutorun {
	Write-Output "Enabling Autorun for all drives..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoDriveTypeAutoRun" -ErrorAction SilentlyContinue
}

# Enable Storage Sense - automatic disk cleanup - Not applicable to Server
Function EnableStorageSense {
	Write-Output "Enabling Storage Sense..."
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "01" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "04" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "08" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "32" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "StoragePoliciesNotified" -Type DWord -Value 1
}

# Disable Storage Sense - Not applicable to Server
Function DisableStorageSense {
	Write-Output "Disabling Storage Sense..."
	Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Recurse -ErrorAction SilentlyContinue
}

# Disable scheduled defragmentation task
Function DisableDefragmentation {
	Write-Output "Disabling scheduled defragmentation..."
	Disable-ScheduledTask -TaskName "Microsoft\Windows\Defrag\ScheduledDefrag" | Out-Null
}

# Enable scheduled defragmentation task
Function EnableDefragmentation {
	Write-Output "Enabling scheduled defragmentation..."
	Enable-ScheduledTask -TaskName "Microsoft\Windows\Defrag\ScheduledDefrag" | Out-Null
}

# Stop and disable Superfetch service - Not applicable to Server
Function DisableSuperfetch {
	Write-Output "Stopping and disabling Superfetch service..."
	Stop-Service "SysMain" -WarningAction SilentlyContinue
	Set-Service "SysMain" -StartupType Disabled
}

# Start and enable Superfetch service - Not applicable to Server
Function EnableSuperfetch {
	Write-Output "Starting and enabling Superfetch service..."
	Set-Service "SysMain" -StartupType Automatic
	Start-Service "SysMain" -WarningAction SilentlyContinue
}

# Stop and disable Windows Search indexing service
Function DisableIndexing {
	Write-Output "Stopping and disabling Windows Search indexing service..."
	Stop-Service "WSearch" -WarningAction SilentlyContinue
	Set-Service "WSearch" -StartupType Disabled
}

# Start and enable Windows Search indexing service
Function EnableIndexing {
	Write-Output "Starting and enabling Windows Search indexing service..."
	Set-Service "WSearch" -StartupType Automatic
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WSearch" -Name "DelayedAutoStart" -Type DWord -Value 1
	Start-Service "WSearch" -WarningAction SilentlyContinue
}

# Set BIOS time to UTC
Function SetBIOSTimeUTC {
	Write-Output "Setting BIOS time to UTC..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Type DWord -Value 1
}

# Set BIOS time to local time
Function SetBIOSTimeLocal {
	Write-Output "Setting BIOS time to Local time..."
	Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -ErrorAction SilentlyContinue
}

# Enable Hibernation - Do not use on Server with automatically started Hyper-V hvboot service as it may lead to BSODs (Win10 with Hyper-V is fine)
Function EnableHibernation {
	Write-Output "Enabling Hibernation..."
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HibernteEnabled" -Type Dword -Value 1
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowHibernateOption" -Type Dword -Value 1
}

# Disable Hibernation
Function DisableHibernation {
	Write-Output "Disabling Hibernation..."
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HibernteEnabled" -Type Dword -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowHibernateOption" -Type Dword -Value 0
}

# Disable Sleep start menu and keyboard button
Function DisableSleepButton {
	Write-Output "Disabling Sleep start menu and keyboard button..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowSleepOption" -Type Dword -Value 0
	powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0
	powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 0
}

# Enable Sleep start menu and keyboard button
Function EnableSleepButton {
	Write-Output "Enabling Sleep start menu and keyboard button..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowSleepOption" -Type Dword -Value 1
	powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1
	powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS SBUTTONACTION 1
}

# Disable display and sleep mode timeouts
Function DisableSleepTimeout {
	Write-Output "Disabling display and sleep mode timeouts..."
	powercfg /X monitor-timeout-ac 0
	powercfg /X monitor-timeout-dc 0
	powercfg /X standby-timeout-ac 0
	powercfg /X standby-timeout-dc 0
}

# Enable display and sleep mode timeouts
Function EnableSleepTimeout {
	Write-Output "Enabling display and sleep mode timeouts..."
	powercfg /X monitor-timeout-ac 10
	powercfg /X monitor-timeout-dc 5
	powercfg /X standby-timeout-ac 30
	powercfg /X standby-timeout-dc 15
}

# Disable Fast Startup
Function DisableFastStartup {
	Write-Output "Disabling Fast Startup..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Type DWord -Value 0
}

# Enable Fast Startup
Function EnableFastStartup {
	Write-Output "Enabling Fast Startup..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberbootEnabled" -Type DWord -Value 1
}



##########
# UI Tweaks
##########

# Disable Action Center
Function DisableActionCenter {
	Write-Output "Disabling Action Center..."
	If (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
		New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Type DWord -Value 0
}

# Enable Action Center
Function EnableActionCenter {
	Write-Output "Enabling Action Center..."
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableNotificationCenter" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -ErrorAction SilentlyContinue
}

# Disable Lock screen
Function DisableLockScreen {
	Write-Output "Disabling Lock screen..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -Type DWord -Value 1
}

# Enable Lock screen
Function EnableLockScreen {
	Write-Output "Enabling Lock screen..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" -Name "NoLockScreen" -ErrorAction SilentlyContinue
}

# Disable Lock screen (Anniversary Update workaround) - Applicable to 1607 - 1803 (The GPO used in DisableLockScreen has been fixed again in 1803)
Function DisableLockScreenRS1 {
	Write-Output "Disabling Lock screen using scheduler workaround..."
	$service = New-Object -com Schedule.Service
	$service.Connect()
	$task = $service.NewTask(0)
	$task.Settings.DisallowStartIfOnBatteries = $false
	$trigger = $task.Triggers.Create(9)
	$trigger = $task.Triggers.Create(11)
	$trigger.StateChange = 8
	$action = $task.Actions.Create(0)
	$action.Path = "reg.exe"
	$action.Arguments = "add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\SessionData /t REG_DWORD /v AllowLockScreen /d 0 /f"
	$service.GetFolder("\").RegisterTaskDefinition("Disable LockScreen", $task, 6, "NT AUTHORITY\SYSTEM", $null, 4) | Out-Null
}

# Enable Lock screen (Anniversary Update workaround) - Applicable to 1607 - 1803
Function EnableLockScreenRS1 {
	Write-Output "Enabling Lock screen (removing scheduler workaround)..."
	Unregister-ScheduledTask -TaskName "Disable LockScreen" -Confirm:$false -ErrorAction SilentlyContinue
}

# Hide network options from Lock Screen
Function HideNetworkFromLockScreen {
	Write-Output "Hiding network options from Lock Screen..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DontDisplayNetworkSelectionUI" -Type DWord -Value 1
}

# Show network options on lock screen
Function ShowNetworkOnLockScreen {
	Write-Output "Showing network options on Lock Screen..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DontDisplayNetworkSelectionUI" -ErrorAction SilentlyContinue
}

# Hide shutdown options from Lock Screen
Function HideShutdownFromLockScreen {
	Write-Output "Hiding shutdown options from Lock Screen..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ShutdownWithoutLogon" -Type DWord -Value 0
}

# Show shutdown options on lock screen
Function ShowShutdownOnLockScreen {
	Write-Output "Showing shutdown options on Lock Screen..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ShutdownWithoutLogon" -Type DWord -Value 1
}

# Disable Sticky keys prompt
Function DisableStickyKeys {
	Write-Output "Disabling Sticky keys prompt..."
	Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "506"
}

# Enable Sticky keys prompt
Function EnableStickyKeys {
	Write-Output "Enabling Sticky keys prompt..."
	Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Type String -Value "510"
}

# Show Task Manager details - Applicable to 1607 and later - Although this functionality exist even in earlier versions, the Task Manager's behavior is different there and is not compatible with this tweak
Function ShowTaskManagerDetails {
	Write-Output "Showing task manager details..."
	$taskmgr = Start-Process -WindowStyle Hidden -FilePath taskmgr.exe -PassThru
	Do {
		Start-Sleep -Milliseconds 100
		$preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
	} Until ($preferences)
	Stop-Process $taskmgr
	$preferences.Preferences[28] = 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value $preferences.Preferences
}

# Hide Task Manager details
Function HideTaskManagerDetails {
	Write-Output "Hiding task manager details..."
	$preferences = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue
	If ($preferences) {
		$preferences.Preferences[28] = 1
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -Type Binary -Value $preferences.Preferences
	}
}

# Show file operations details
Function ShowFileOperationsDetails {
	Write-Output "Showing file operations details..."
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Name "EnthusiastMode" -Type DWord -Value 1
}

# Hide file operations details
Function HideFileOperationsDetails {
	Write-Output "Hiding file operations details..."
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" -Name "EnthusiastMode" -ErrorAction SilentlyContinue
}

# Enable file delete confirmation dialog
Function EnableFileDeleteConfirm {
	Write-Output "Enabling file delete confirmation dialog..."
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ConfirmFileDelete" -Type DWord -Value 1
}

# Disable file delete confirmation dialog
Function DisableFileDeleteConfirm {
	Write-Output "Disabling file delete confirmation dialog..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ConfirmFileDelete" -ErrorAction SilentlyContinue
}

# Hide Taskbar Search icon / box
Function HideTaskbarSearch {
	Write-Output "Hiding Taskbar Search icon / box..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0
}

# Show Taskbar Search icon
Function ShowTaskbarSearchIcon {
	Write-Output "Showing Taskbar Search icon..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 1
}

# Show Taskbar Search box
Function ShowTaskbarSearchBox {
	Write-Output "Showing Taskbar Search box..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 2
}

# Hide Task View button
Function HideTaskView {
	Write-Output "Hiding Task View button..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWord -Value 0
}

# Show Task View button
Function ShowTaskView {
	Write-Output "Showing Task View button..."
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -ErrorAction SilentlyContinue
}

# Show small icons in taskbar
Function ShowSmallTaskbarIcons {
	Write-Output "Showing small icons in taskbar..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSmallIcons" -Type DWord -Value 1
}

# Show large icons in taskbar
Function ShowLargeTaskbarIcons {
	Write-Output "Showing large icons in taskbar..."
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSmallIcons" -ErrorAction SilentlyContinue
}

# Set taskbar buttons to show labels and combine when taskbar is full
Function SetTaskbarCombineWhenFull {
	Write-Output "Setting taskbar buttons to combine when taskbar is full..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -Type DWord -Value 1
}

# Set taskbar buttons to show labels and never combine
Function SetTaskbarCombineNever {
	Write-Output "Setting taskbar buttons to never combine..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -Type DWord -Value 2
}

# Set taskbar buttons to always combine and hide labels
Function SetTaskbarCombineAlways {
	Write-Output "Setting taskbar buttons to always combine, hide labels..."
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -ErrorAction SilentlyContinue
}

# Hide Taskbar People icon
Function HideTaskbarPeopleIcon {
	Write-Output "Hiding People icon..."
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Type DWord -Value 0
}

# Show Taskbar People icon
Function ShowTaskbarPeopleIcon {
	Write-Output "Showing People icon..."
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -ErrorAction SilentlyContinue
}

# Show all tray icons
Function ShowTrayIcons {
	Write-Output "Showing all tray icons..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -Type DWord -Value 0
}

# Hide tray icons as needed
Function HideTrayIcons {
	Write-Output "Hiding tray icons..."
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "EnableAutoTray" -ErrorAction SilentlyContinue
}

# Disable search for app in store for unknown extensions
Function DisableSearchAppInStore {
	Write-Output "Disabling search for app in store for unknown extensions..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -Type DWord -Value 1
}

# Enable search for app in store for unknown extensions
Function EnableSearchAppInStore {
	Write-Output "Enabling search for app in store for unknown extensions..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoUseStoreOpenWith" -ErrorAction SilentlyContinue
}

# Disable 'How do you want to open this file?' prompt
Function DisableNewAppPrompt {
	Write-Output "Disabling 'How do you want to open this file?' prompt..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoNewAppAlert" -Type DWord -Value 1
}

# Enable 'How do you want to open this file?' prompt
Function EnableNewAppPrompt {
	Write-Output "Enabling 'How do you want to open this file?' prompt..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "NoNewAppAlert" -ErrorAction SilentlyContinue
}

# Set Control Panel view to Small icons (Classic)
Function SetControlPanelSmallIcons {
	Write-Output "Setting Control Panel view to small icons..."
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "StartupPage" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "AllItemsIconView" -Type DWord -Value 1
}

# Set Control Panel view to Large icons (Classic)
Function SetControlPanelLargeIcons {
	Write-Output "Setting Control Panel view to large icons..."
	If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel")) {
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "StartupPage" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "AllItemsIconView" -Type DWord -Value 0
}

# Set Control Panel view to categories
Function SetControlPanelCategories {
	Write-Output "Setting Control Panel view to categories..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "StartupPage" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "AllItemsIconView" -ErrorAction SilentlyContinue
}

# Adjusts visual effects for performance - Disables animations, transparency etc. but leaves font smoothing and miniatures enabled
Function SetVisualFXPerformance {
	Write-Output "Adjusting visual effects for performance..."
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Type String -Value 0
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value 0
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary -Value ([byte[]](144,18,3,128,16,0,0,0))
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type String -Value 0
	Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWord -Value 3
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Type DWord -Value 0
}

# Adjusts visual effects for appearance
Function SetVisualFXAppearance {
	Write-Output "Adjusting visual effects for appearance..."
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "DragFullWindows" -Type String -Value 1
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Type String -Value 400
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Type Binary -Value ([byte[]](158,30,7,128,18,0,0,0))
	Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Type String -Value 1
	Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewAlphaSelect" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ListviewShadow" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAnimations" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Type DWord -Value 3
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "EnableAeroPeek" -Type DWord -Value 1
}

# Add secondary en-US keyboard
Function AddENKeyboard {
	Write-Output "Adding secondary en-US keyboard..."
	$langs = Get-WinUserLanguageList
	$langs.Add("en-US")
	Set-WinUserLanguageList $langs -Force
}

# Remove secondary en-US keyboard
Function RemoveENKeyboard {
	Write-Output "Removing secondary en-US keyboard..."
	$langs = Get-WinUserLanguageList
	Set-WinUserLanguageList ($langs | ? {$_.LanguageTag -ne "en-US"}) -Force
}

# Enable NumLock after startup
Function EnableNumlock {
	Write-Output "Enabling NumLock after startup..."
	If (!(Test-Path "HKU:")) {
		New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | Out-Null
	}
	Set-ItemProperty -Path "HKU:\.DEFAULT\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Type DWord -Value 2147483650
	Add-Type -AssemblyName System.Windows.Forms
	If (!([System.Windows.Forms.Control]::IsKeyLocked('NumLock'))) {
		$wsh = New-Object -ComObject WScript.Shell
		$wsh.SendKeys('{NUMLOCK}')
	}
}

# Disable NumLock after startup
Function DisableNumlock {
	Write-Output "Disabling NumLock after startup..."
	If (!(Test-Path "HKU:")) {
		New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS | Out-Null
	}
	Set-ItemProperty -Path "HKU:\.DEFAULT\Control Panel\Keyboard" -Name "InitialKeyboardIndicators" -Type DWord -Value 2147483648
	Add-Type -AssemblyName System.Windows.Forms
	If ([System.Windows.Forms.Control]::IsKeyLocked('NumLock')) {
		$wsh = New-Object -ComObject WScript.Shell
		$wsh.SendKeys('{NUMLOCK}')
	}
}



##########
# Explorer UI Tweaks
##########

# Show known file extensions
Function ShowKnownExtensions {
	Write-Output "Showing known file extensions..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0
}

# Hide known file extensions
Function HideKnownExtensions {
	Write-Output "Hiding known file extensions..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 1
}

# Show hidden files
Function ShowHiddenFiles {
	Write-Output "Showing hidden files..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1
}

# Hide hidden files
Function HideHiddenFiles {
	Write-Output "Hiding hidden files..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 2
}

# Hide sync provider notifications
Function HideSyncNotifications {
	Write-Output "Hiding sync provider notifications..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 0
}

# Show sync provider notifications
Function ShowSyncNotifications {
	Write-Output "Showing sync provider notifications..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Type DWord -Value 1
}

# Hide recently and frequently used item shortcuts in Explorer
Function HideRecentShortcuts {
	Write-Output "Hiding recent shortcuts..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Type DWord -Value 0
}

# Show recently and frequently used item shortcuts in Explorer
Function ShowRecentShortcuts {
	Write-Output "Showing recent shortcuts..."
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -ErrorAction SilentlyContinue
}

# Change default Explorer view to This PC
Function SetExplorerThisPC {
	Write-Output "Changing default Explorer view to This PC..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1
}

# Change default Explorer view to Quick Access
Function SetExplorerQuickAccess {
	Write-Output "Changing default Explorer view to Quick Access..."
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -ErrorAction SilentlyContinue
}

# Show This PC shortcut on desktop
Function ShowThisPCOnDesktop {
	Write-Output "Showing This PC shortcut on desktop..."
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0
}

# Hide This PC shortcut from desktop
Function HideThisPCFromDesktop {
	Write-Output "Hiding This PC shortcut from desktop..."
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -ErrorAction SilentlyContinue
}

# Show User Folder shortcut on desktop
Function ShowUserFolderOnDesktop {
	Write-Output "Showing User Folder shortcut on desktop..."
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Type DWord -Value 0
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -Type DWord -Value 0
}

# Hide User Folder shortcut from desktop
Function HideUserFolderFromDesktop {
	Write-Output "Hiding User Folder shortcut from desktop..."
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" -ErrorAction SilentlyContinue
}

# Hide Desktop icon from This PC - The icon remains in personal folders and open/save dialogs
Function HideDesktopFromThisPC {
	Write-Output "Hiding Desktop icon from This PC..."
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" -Recurse -ErrorAction SilentlyContinue
}

# Show Desktop icon in This PC
Function ShowDesktopInThisPC {
	Write-Output "Showing Desktop icon in This PC..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" | Out-Null
	}
}

# Hide Desktop icon from Explorer namespace - Hides the icon also from personal folders and open/save dialogs
Function HideDesktopFromExplorer {
	Write-Output "Hiding Desktop icon from Explorer namespace..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
}

# Show Desktop icon in Explorer namespace
Function ShowDesktopInExplorer {
	Write-Output "Showing Desktop icon in Explorer namespace..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"
}

# Hide Documents icon from This PC - The icon remains in personal folders and open/save dialogs
Function HideDocumentsFromThisPC {
	Write-Output "Hiding Documents icon from This PC..."
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" -Recurse -ErrorAction SilentlyContinue
}

# Show Documents icon in This PC
Function ShowDocumentsInThisPC {
	Write-Output "Showing Documents icon in This PC..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" | Out-Null
	}
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" | Out-Null
	}
}

# Hide Documents icon from Explorer namespace - Hides the icon also from personal folders and open/save dialogs
Function HideDocumentsFromExplorer {
	Write-Output "Hiding Documents icon from Explorer namespace..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
}

# Show Documents icon in Explorer namespace
Function ShowDocumentsInExplorer {
	Write-Output "Showing Documents icon in Explorer namespace..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{f42ee2d3-909f-4907-8871-4c22fc0bf756}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"
}

# Hide Downloads icon from This PC - The icon remains in personal folders and open/save dialogs
Function HideDownloadsFromThisPC {
	Write-Output "Hiding Downloads icon from This PC..."
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" -Recurse -ErrorAction SilentlyContinue
}

# Show Downloads icon in This PC
Function ShowDownloadsInThisPC {
	Write-Output "Showing Downloads icon in This PC..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" | Out-Null
	}
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" | Out-Null
	}
}

# Hide Downloads icon from Explorer namespace - Hides the icon also from personal folders and open/save dialogs
Function HideDownloadsFromExplorer {
	Write-Output "Hiding Downloads icon from Explorer namespace..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
}

# Show Downloads icon in Explorer namespace
Function ShowDownloadsInExplorer {
	Write-Output "Showing Downloads icon in Explorer namespace..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{7d83ee9b-2244-4e70-b1f5-5393042af1e4}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"
}

# Hide Music icon from This PC - The icon remains in personal folders and open/save dialogs
Function HideMusicFromThisPC {
	Write-Output "Hiding Music icon from This PC..."
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" -Recurse -ErrorAction SilentlyContinue
}

# Show Music icon in This PC
Function ShowMusicInThisPC {
	Write-Output "Showing Music icon in This PC..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" | Out-Null
	}
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" | Out-Null
	}
}

# Hide Music icon from Explorer namespace - Hides the icon also from personal folders and open/save dialogs
Function HideMusicFromExplorer {
	Write-Output "Hiding Music icon from Explorer namespace..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
}

# Show Music icon in Explorer namespace
Function ShowMusicInExplorer {
	Write-Output "Showing Music icon in Explorer namespace..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{a0c69a99-21c8-4671-8703-7934162fcf1d}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"
}

# Hide Pictures icon from This PC - The icon remains in personal folders and open/save dialogs
Function HidePicturesFromThisPC {
	Write-Output "Hiding Pictures icon from This PC..."
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" -Recurse -ErrorAction SilentlyContinue
}

# Show Pictures icon in This PC
Function ShowPicturesInThisPC {
	Write-Output "Showing Pictures icon in This PC..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" | Out-Null
	}
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" | Out-Null
	}
}

# Hide Pictures icon from Explorer namespace - Hides the icon also from personal folders and open/save dialogs
Function HidePicturesFromExplorer {
	Write-Output "Hiding Pictures icon from Explorer namespace..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
}

# Show Pictures icon in Explorer namespace
Function ShowPicturesInExplorer {
	Write-Output "Showing Pictures icon in Explorer namespace..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{0ddd015d-b06c-45d5-8c4c-f59713854639}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"
}

# Hide Videos icon from This PC - The icon remains in personal folders and open/save dialogs
Function HideVideosFromThisPC {
	Write-Output "Hiding Videos icon from This PC..."
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" -Recurse -ErrorAction SilentlyContinue
}

# Show Videos icon in This PC
Function ShowVideosInThisPC {
	Write-Output "Showing Videos icon in This PC..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" | Out-Null
	}
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" | Out-Null
	}
}

# Hide Videos icon from Explorer namespace - Hides the icon also from personal folders and open/save dialogs
Function HideVideosFromExplorer {
	Write-Output "Hiding Videos icon from Explorer namespace..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
}

# Show Videos icon in Explorer namespace
Function ShowVideosInExplorer {
	Write-Output "Showing Videos icon in Explorer namespace..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{35286a68-3c57-41a1-bbb1-0eae73d76c95}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Show"
}

# Hide 3D Objects icon from This PC - The icon remains in personal folders and open/save dialogs
Function Hide3DObjectsFromThisPC {
	Write-Output "Hiding 3D Objects icon from This PC..."
	Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Recurse -ErrorAction SilentlyContinue
}

# Show 3D Objects icon in This PC
Function Show3DObjectsInThisPC {
	Write-Output "Showing 3D Objects icon in This PC..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" | Out-Null
	}
}

# Hide 3D Objects icon from Explorer namespace - Hides the icon also from personal folders and open/save dialogs
Function Hide3DObjectsFromExplorer {
	Write-Output "Hiding 3D Objects icon from Explorer namespace..."
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
	If (!(Test-Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag")) {
		New-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -Type String -Value "Hide"
}

# Show 3D Objects icon in Explorer namespace
Function Show3DObjectsInExplorer {
	Write-Output "Showing 3D Objects icon in Explorer namespace..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\FolderDescriptions\{31C0DD25-9439-4F12-BF41-7FF4EDA38722}\PropertyBag" -Name "ThisPCPolicy" -ErrorAction SilentlyContinue
}

# Disable thumbnails, show only file extension icons
Function DisableThumbnails {
	Write-Output "Disabling thumbnails..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Type DWord -Value 1
}

# Enable thumbnails
Function EnableThumbnails {
	Write-Output "Enabling thumbnails..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "IconsOnly" -Type DWord -Value 0
}

# Disable creation of Thumbs.db thumbnail cache files
Function DisableThumbsDB {
	Write-Output "Disabling creation of Thumbs.db..."
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisableThumbnailCache" -Type DWord -Value 1
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisableThumbsDBOnNetworkFolders" -Type DWord -Value 1
}

# Enable creation of Thumbs.db thumbnail cache files
Function EnableThumbsDB {
	Write-Output "Enable creation of Thumbs.db..."
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisableThumbnailCache" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "DisableThumbsDBOnNetworkFolders" -ErrorAction SilentlyContinue
}



##########
# Application Tweaks
##########

# Disable OneDrive
Function DisableOneDrive {
	Write-Output "Disabling OneDrive..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1
}

# Enable OneDrive
Function EnableOneDrive {
	Write-Output "Enabling OneDrive..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -ErrorAction SilentlyContinue
}

# Uninstall OneDrive - Not applicable to Server
Function UninstallOneDrive {
	Write-Output "Uninstalling OneDrive..."
	Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
	Start-Sleep -s 2
	$onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
	If (!(Test-Path $onedrive)) {
		$onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
	}
	Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
	Start-Sleep -s 2
	Stop-Process -Name "explorer" -Force -ErrorAction SilentlyContinue
	Start-Sleep -s 2
	Remove-Item -Path "$env:USERPROFILE\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "$env:PROGRAMDATA\Microsoft OneDrive" -Force -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse -ErrorAction SilentlyContinue
	If (!(Test-Path "HKCR:")) {
		New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
	}
	Remove-Item -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
}

# Install OneDrive - Not applicable to Server
Function InstallOneDrive {
	Write-Output "Installing OneDrive..."
	$onedrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"
	If (!(Test-Path $onedrive)) {
		$onedrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"
	}
	Start-Process $onedrive -NoNewWindow
}

# Uninstall default Microsoft applications
Function UninstallMsftBloat {
	Write-Output "Uninstalling default Microsoft applications..."
	Get-AppxPackage "Microsoft.3DBuilder" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.AppConnector" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingFinance" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingNews" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingSports" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingTranslator" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingWeather" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.CommsPhone" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.ConnectivityStore" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.GetHelp" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Getstarted" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Messaging" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Microsoft3DViewer" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MicrosoftOfficeHub" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MicrosoftPowerBIForWindows" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MicrosoftSolitaireCollection" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MicrosoftStickyNotes" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MinecraftUWP" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MSPaint" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.NetworkSpeedTest" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Office.OneNote" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Office.Sway" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.OneConnect" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.People" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Print3D" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.RemoteDesktop" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.SkypeApp" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Wallet" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsAlarms" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsCamera" | Remove-AppxPackage
	Get-AppxPackage "microsoft.windowscommunicationsapps" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsFeedbackHub" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsMaps" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsPhone" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Windows.Photos" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsSoundRecorder" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.ZuneMusic" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.ZuneVideo" | Remove-AppxPackage
}

# Install default Microsoft applications
Function InstallMsftBloat {
	Write-Output "Installing default Microsoft applications..."
	Get-AppxPackage -AllUsers "Microsoft.3DBuilder" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.AppConnector" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.BingFinance" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.BingNews" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.BingSports" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.BingTranslator" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.BingWeather" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.CommsPhone" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.ConnectivityStore" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.GetHelp" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Getstarted" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Messaging" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Microsoft3DViewer" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.MicrosoftOfficeHub" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.MicrosoftPowerBIForWindows" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.MicrosoftSolitaireCollection" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.MicrosoftStickyNotes" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.MinecraftUWP" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.MSPaint" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.NetworkSpeedTest" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Office.OneNote" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Office.Sway" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.OneConnect" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.People" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Print3D" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.RemoteDesktop" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.SkypeApp" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Wallet" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WindowsAlarms" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WindowsCamera" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.windowscommunicationsapps" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WindowsFeedbackHub" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WindowsMaps" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WindowsPhone" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Windows.Photos" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WindowsSoundRecorder" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.ZuneMusic" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.ZuneVideo" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
}
# In case you have removed them for good, you can try to restore the files using installation medium as follows
# New-Item C:\Mnt -Type Directory | Out-Null
# dism /Mount-Image /ImageFile:D:\sources\install.wim /index:1 /ReadOnly /MountDir:C:\Mnt
# robocopy /S /SEC /R:0 "C:\Mnt\Program Files\WindowsApps" "C:\Program Files\WindowsApps"
# dism /Unmount-Image /Discard /MountDir:C:\Mnt
# Remove-Item -Path C:\Mnt -Recurse

# Uninstall default third party applications
function UninstallThirdPartyBloat {
	Write-Output "Uninstalling default third party applications..."
	Get-AppxPackage "2414FC7A.Viber" | Remove-AppxPackage
	Get-AppxPackage "41038Axilesoft.ACGMediaPlayer" | Remove-AppxPackage
	Get-AppxPackage "46928bounde.EclipseManager" | Remove-AppxPackage
	Get-AppxPackage "4DF9E0F8.Netflix" | Remove-AppxPackage
	Get-AppxPackage "64885BlueEdge.OneCalendar" | Remove-AppxPackage
	Get-AppxPackage "7EE7776C.LinkedInforWindows" | Remove-AppxPackage
	Get-AppxPackage "828B5831.HiddenCityMysteryofShadows" | Remove-AppxPackage
	Get-AppxPackage "89006A2E.AutodeskSketchBook" | Remove-AppxPackage
	Get-AppxPackage "9E2F88E3.Twitter" | Remove-AppxPackage
	Get-AppxPackage "A278AB0D.DisneyMagicKingdoms" | Remove-AppxPackage
	Get-AppxPackage "A278AB0D.MarchofEmpires" | Remove-AppxPackage
	Get-AppxPackage "ActiproSoftwareLLC.562882FEEB491" | Remove-AppxPackage
	Get-AppxPackage "AdobeSystemsIncorporated.AdobePhotoshopExpress" | Remove-AppxPackage
	Get-AppxPackage "CAF9E577.Plex" | Remove-AppxPackage
	Get-AppxPackage "D52A8D61.FarmVille2CountryEscape" | Remove-AppxPackage
	Get-AppxPackage "D5EA27B7.Duolingo-LearnLanguagesforFree" | Remove-AppxPackage
	Get-AppxPackage "DB6EA5DB.CyberLinkMediaSuiteEssentials" | Remove-AppxPackage
	Get-AppxPackage "DolbyLaboratories.DolbyAccess" | Remove-AppxPackage
	Get-AppxPackage "Drawboard.DrawboardPDF" | Remove-AppxPackage
	Get-AppxPackage "Facebook.Facebook" | Remove-AppxPackage
	Get-AppxPackage "flaregamesGmbH.RoyalRevolt2" | Remove-AppxPackage
	Get-AppxPackage "GAMELOFTSA.Asphalt8Airborne" | Remove-AppxPackage
	Get-AppxPackage "KeeperSecurityInc.Keeper" | Remove-AppxPackage
	Get-AppxPackage "king.com.BubbleWitch3Saga" | Remove-AppxPackage
	Get-AppxPackage "king.com.CandyCrushSodaSaga" | Remove-AppxPackage
	Get-AppxPackage "PandoraMediaInc.29680B314EFC2" | Remove-AppxPackage
	Get-AppxPackage "SpotifyAB.SpotifyMusic" | Remove-AppxPackage
	Get-AppxPackage "WinZipComputing.WinZipUniversal" | Remove-AppxPackage
	Get-AppxPackage "XINGAG.XING" | Remove-AppxPackage
}

# Install default third party applications
Function InstallThirdPartyBloat {
	Write-Output "Installing default third party applications..."
	Get-AppxPackage -AllUsers "2414FC7A.Viber" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "41038Axilesoft.ACGMediaPlayer" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "46928bounde.EclipseManager" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "4DF9E0F8.Netflix" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "64885BlueEdge.OneCalendar" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "7EE7776C.LinkedInforWindows" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "828B5831.HiddenCityMysteryofShadows" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "89006A2E.AutodeskSketchBook" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "9E2F88E3.Twitter" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "A278AB0D.DisneyMagicKingdoms" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "A278AB0D.MarchofEmpires" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "ActiproSoftwareLLC.562882FEEB491" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "AdobeSystemsIncorporated.AdobePhotoshopExpress" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "CAF9E577.Plex" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "D52A8D61.FarmVille2CountryEscape" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "D5EA27B7.Duolingo-LearnLanguagesforFree" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "DB6EA5DB.CyberLinkMediaSuiteEssentials" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "DolbyLaboratories.DolbyAccess" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Drawboard.DrawboardPDF" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Facebook.Facebook" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "flaregamesGmbH.RoyalRevolt2" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "GAMELOFTSA.Asphalt8Airborne" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "KeeperSecurityInc.Keeper" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "king.com.BubbleWitch3Saga" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "king.com.CandyCrushSodaSaga" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "PandoraMediaInc.29680B314EFC2" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "SpotifyAB.SpotifyMusic" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "WinZipComputing.WinZipUniversal" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "XINGAG.XING" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
}

# Uninstall Windows Store
Function UninstallWindowsStore {
	Write-Output "Uninstalling Windows Store..."
	Get-AppxPackage "Microsoft.DesktopAppInstaller" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsStore" | Remove-AppxPackage
}

# Install Windows Store
Function InstallWindowsStore {
	Write-Output "Installing Windows Store..."
	Get-AppxPackage -AllUsers "Microsoft.DesktopAppInstaller" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.WindowsStore" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
}

# Disable Xbox features
Function DisableXboxFeatures {
	Write-Output "Disabling Xbox features..."
	Get-AppxPackage "Microsoft.XboxApp" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.XboxIdentityProvider" | Remove-AppxPackage -ErrorAction SilentlyContinue
	Get-AppxPackage "Microsoft.XboxSpeechToTextOverlay" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.XboxGameOverlay" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Xbox.TCUI" | Remove-AppxPackage
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0
}

# Enable Xbox features
Function EnableXboxFeatures {
	Write-Output "Enabling Xbox features..."
	Get-AppxPackage -AllUsers "Microsoft.XboxApp" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.XboxIdentityProvider" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.XboxSpeechToTextOverlay" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.XboxGameOverlay" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Get-AppxPackage -AllUsers "Microsoft.Xbox.TCUI" | ForEach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 1
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -ErrorAction SilentlyContinue
}

# Disable built-in Adobe Flash in IE and Edge
Function DisableAdobeFlash {
	Write-Output "Disabling built-in Adobe Flash in IE and Edge..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer" -Name "DisableFlashInIE" -Type DWord -Value 1
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Addons")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Addons" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Addons" -Name "FlashPlayerEnabled" -Type DWord -Value 0
}

# Enable built-in Adobe Flash in IE and Edge
Function EnableAdobeFlash {
	Write-Output "Enabling built-in Adobe Flash in IE and Edge..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer" -Name "DisableFlashInIE" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Addons" -Name "FlashPlayerEnabled" -ErrorAction SilentlyContinue
}

# Uninstall Windows Media Player
Function UninstallMediaPlayer {
	Write-Output "Uninstalling Windows Media Player..."
	Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Install Windows Media Player
Function InstallMediaPlayer {
	Write-Output "Installing Windows Media Player..."
	Enable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Uninstall Internet Explorer
Function UninstallInternetExplorer {
	Write-Output "Uninstalling Internet Explorer..."
	Disable-WindowsOptionalFeature -Online -FeatureName "Internet-Explorer-Optional-$env:PROCESSOR_ARCHITECTURE" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Install Internet Explorer
Function InstallInternetExplorer {
	Write-Output "Installing Internet Explorer..."
	Enable-WindowsOptionalFeature -Online -FeatureName "Internet-Explorer-Optional-$env:PROCESSOR_ARCHITECTURE" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Uninstall Work Folders Client - Not applicable to Server
Function UninstallWorkFolders {
	Write-Output "Uninstalling Work Folders Client..."
	Disable-WindowsOptionalFeature -Online -FeatureName "WorkFolders-Client" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Install Work Folders Client - Not applicable to Server
Function InstallWorkFolders {
	Write-Output "Installing Work Folders Client..."
	Enable-WindowsOptionalFeature -Online -FeatureName "WorkFolders-Client" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Install Linux Subsystem - Applicable to 1607 or newer
Function InstallLinuxSubsystem {
	Write-Output "Installing Linux Subsystem..."
	If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
		# 1607 needs developer mode to be enabled
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 1
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -Type DWord -Value 1
	}
	Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Uninstall Linux Subsystem - Applicable to 1607 or newer
Function UninstallLinuxSubsystem {
	Write-Output "Uninstalling Linux Subsystem..."
	If ([System.Environment]::OSVersion.Version.Build -eq 14393) {
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -Type DWord -Value 0
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowAllTrustedApps" -Type DWord -Value 0
	}
	Disable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Install Hyper-V - Not applicable to Home
Function InstallHyperV {
	Write-Output "Installing Hyper-V..."
	If ((Get-WmiObject -Class "Win32_OperatingSystem").Caption -like "*Server*") {
		Install-WindowsFeature -Name "Hyper-V" -IncludeManagementTools -WarningAction SilentlyContinue | Out-Null
	} Else {
		Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -NoRestart -WarningAction SilentlyContinue | Out-Null
	}
}

# Uninstall Hyper-V - Not applicable to Home
Function UninstallHyperV {
	Write-Output "Uninstalling Hyper-V..."
	If ((Get-WmiObject -Class "Win32_OperatingSystem").Caption -like "*Server*") {
		Uninstall-WindowsFeature -Name "Hyper-V" -IncludeManagementTools -WarningAction SilentlyContinue | Out-Null
	} Else {
		Disable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -NoRestart -WarningAction SilentlyContinue | Out-Null
	}
}

# Set Photo Viewer association for bmp, gif, jpg, png and tif
Function SetPhotoViewerAssociation {
	Write-Output "Setting Photo Viewer association for bmp, gif, jpg, png and tif..."
	If (!(Test-Path "HKCR:")) {
		New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
	}
	ForEach ($type in @("Paint.Picture", "giffile", "jpegfile", "pngfile")) {
		New-Item -Path $("HKCR:\$type\shell\open") -Force | Out-Null
		New-Item -Path $("HKCR:\$type\shell\open\command") | Out-Null
		Set-ItemProperty -Path $("HKCR:\$type\shell\open") -Name "MuiVerb" -Type ExpandString -Value "@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043"
		Set-ItemProperty -Path $("HKCR:\$type\shell\open\command") -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
	}
}

# Unset Photo Viewer association for bmp, gif, jpg, png and tif
Function UnsetPhotoViewerAssociation {
	Write-Output "Unsetting Photo Viewer association for bmp, gif, jpg, png and tif..."
	If (!(Test-Path "HKCR:")) {
		New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
	}
	Remove-Item -Path "HKCR:\Paint.Picture\shell\open" -Recurse -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCR:\giffile\shell\open" -Name "MuiVerb" -ErrorAction SilentlyContinue
	Set-ItemProperty -Path "HKCR:\giffile\shell\open" -Name "CommandId" -Type String -Value "IE.File"
	Set-ItemProperty -Path "HKCR:\giffile\shell\open\command" -Name "(Default)" -Type String -Value "`"$env:SystemDrive\Program Files\Internet Explorer\iexplore.exe`" %1"
	Set-ItemProperty -Path "HKCR:\giffile\shell\open\command" -Name "DelegateExecute" -Type String -Value "{17FE9752-0B5A-4665-84CD-569794602F5C}"
	Remove-Item -Path "HKCR:\jpegfile\shell\open" -Recurse -ErrorAction SilentlyContinue
	Remove-Item -Path "HKCR:\pngfile\shell\open" -Recurse -ErrorAction SilentlyContinue
}

# Add Photo Viewer to "Open with..."
Function AddPhotoViewerOpenWith {
	Write-Output "Adding Photo Viewer to `"Open with...`""
	If (!(Test-Path "HKCR:")) {
		New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
	}
	New-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open\command" -Force | Out-Null
	New-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open\DropTarget" -Force | Out-Null
	Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open" -Name "MuiVerb" -Type String -Value "@photoviewer.dll,-3043"
	Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open\command" -Name "(Default)" -Type ExpandString -Value "%SystemRoot%\System32\rundll32.exe `"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll`", ImageView_Fullscreen %1"
	Set-ItemProperty -Path "HKCR:\Applications\photoviewer.dll\shell\open\DropTarget" -Name "Clsid" -Type String -Value "{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"
}

# Remove Photo Viewer from "Open with..."
Function RemovePhotoViewerOpenWith {
	Write-Output "Removing Photo Viewer from `"Open with...`""
	If (!(Test-Path "HKCR:")) {
		New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
	}
	Remove-Item -Path "HKCR:\Applications\photoviewer.dll\shell\open" -Recurse -ErrorAction SilentlyContinue
}

# Uninstall Microsoft Print to PDF
Function UninstallPDFPrinter {
	Write-Output "Uninstalling Microsoft Print to PDF..."
	Disable-WindowsOptionalFeature -Online -FeatureName "Printing-PrintToPDFServices-Features" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Install Microsoft Print to PDF
Function InstallPDFPrinter {
	Write-Output "Installing Microsoft Print to PDF..."
	Enable-WindowsOptionalFeature -Online -FeatureName "Printing-PrintToPDFServices-Features" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Uninstall Microsoft XPS Document Writer
Function UninstallXPSPrinter {
	Write-Output "Uninstalling Microsoft XPS Document Writer..."
	Disable-WindowsOptionalFeature -Online -FeatureName "Printing-XPSServices-Features" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Install Microsoft XPS Document Writer
Function InstallXPSPrinter {
	Write-Output "Installing Microsoft XPS Document Writer..."
	Enable-WindowsOptionalFeature -Online -FeatureName "Printing-XPSServices-Features" -NoRestart -WarningAction SilentlyContinue | Out-Null
}

# Remove Default Fax Printer
Function RemoveFaxPrinter {
	Write-Output "Removing Default Fax Printer..."
	Remove-Printer -Name "Fax" -ErrorAction SilentlyContinue
}

# Add Default Fax Printer
Function AddFaxPrinter {
	Write-Output "Adding Default Fax Printer..."
	Add-Printer -Name "Fax" -DriverName "Microsoft Shared Fax Driver" -PortName "SHRFAX:" -ErrorAction SilentlyContinue
}



##########
# Server specific Tweaks
##########

# Hide Server Manager after login
Function HideServerManagerOnLogin {
	Write-Output "Hiding Server Manager after login..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Server\ServerManager")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Server\ServerManager" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Server\ServerManager" -Name "DoNotOpenAtLogon" -Type DWord -Value 1
}

# Hide Server Manager after login
Function ShowServerManagerOnLogin {
	Write-Output "Showing Server Manager after login..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Server\ServerManager" -Name "DoNotOpenAtLogon" -ErrorAction SilentlyContinue
}

# Disable Shutdown Event Tracker
Function DisableShutdownTracker {
	Write-Output "Disabling Shutdown Event Tracker..."
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Force | Out-Null
	}
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Name "ShutdownReasonOn" -Type DWord -Value 0
}

# Enable Shutdown Event Tracker
Function EnableShutdownTracker {
	Write-Output "Enabling Shutdown Event Tracker..."
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Name "ShutdownReasonOn" -ErrorAction SilentlyContinue
}

# Disable password complexity and maximum age requirements
Function DisablePasswordPolicy {
	Write-Output "Disabling password complexity and maximum age requirements..."
	$tmpfile = New-TemporaryFile
	secedit /export /cfg $tmpfile /quiet
	(Get-Content $tmpfile).Replace("PasswordComplexity = 1", "PasswordComplexity = 0").Replace("MaximumPasswordAge = 42", "MaximumPasswordAge = -1") | Out-File $tmpfile
	secedit /configure /db "$env:SYSTEMROOT\security\database\local.sdb" /cfg $tmpfile /areas SECURITYPOLICY | Out-Null
	Remove-Item -Path $tmpfile
}

# Enable password complexity and maximum age requirements
Function EnablePasswordPolicy {
	Write-Output "Enabling password complexity and maximum age requirements..."
	$tmpfile = New-TemporaryFile
	secedit /export /cfg $tmpfile /quiet
	(Get-Content $tmpfile).Replace("PasswordComplexity = 0", "PasswordComplexity = 1").Replace("MaximumPasswordAge = -1", "MaximumPasswordAge = 42") | Out-File $tmpfile
	secedit /configure /db "$env:SYSTEMROOT\security\database\local.sdb" /cfg $tmpfile /areas SECURITYPOLICY | Out-Null
	Remove-Item -Path $tmpfile
}

# Disable Ctrl+Alt+Del requirement before login
Function DisableCtrlAltDelLogin {
	Write-Output "Disabling Ctrl+Alt+Del requirement before login..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableCAD" -Type DWord -Value 1
}

# Enable Ctrl+Alt+Del requirement before login
Function EnableCtrlAltDelLogin {
	Write-Output "Enabling Ctrl+Alt+Del requirement before login..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableCAD" -Type DWord -Value 0
}

# Disable Internet Explorer Enhanced Security Configuration (IE ESC)
Function DisableIEEnhancedSecurity {
	Write-Output "Disabling Internet Explorer Enhanced Security Configuration (IE ESC)..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Type DWord -Value 0
}

# Enable Internet Explorer Enhanced Security Configuration (IE ESC)
Function EnableIEEnhancedSecurity {
	Write-Output "Enabling Internet Explorer Enhanced Security Configuration (IE ESC)..."
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Type DWord -Value 1
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}" -Name "IsInstalled" -Type DWord -Value 1
}

# Enable Audio
Function EnableAudio {
	Write-Output "Enabling Audio..."
	Set-Service "Audiosrv" -StartupType Automatic
	Start-Service "Audiosrv" -WarningAction SilentlyContinue
}

# Disable Audio
Function DisableAudio {
	Write-Output "Disabling Audio..."
	Stop-Service "Audiosrv" -WarningAction SilentlyContinue
	Set-Service "Audiosrv" -StartupType Manual
}



##########
# Unpinning
##########

# Unpin all Start Menu tiles - Note: This function has no counterpart. You have to pin the tiles back manually.
Function UnpinStartMenuTiles {
	Write-Output "Unpinning all Start Menu tiles..."
	If ([System.Environment]::OSVersion.Version.Build -ge 15063 -And [System.Environment]::OSVersion.Version.Build -le 16299) {
		Get-ChildItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" -Include "*.group" -Recurse | ForEach-Object {
			$data = (Get-ItemProperty -Path "$($_.PsPath)\Current" -Name "Data").Data -Join ","
			$data = $data.Substring(0, $data.IndexOf(",0,202,30") + 9) + ",0,202,80,0,0"
			Set-ItemProperty -Path "$($_.PsPath)\Current" -Name "Data" -Type Binary -Value $data.Split(",")
		}
	} ElseIf ([System.Environment]::OSVersion.Version.Build -eq 17133) {
		$key = Get-ChildItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" -Recurse | Where-Object { $_ -like "*start.tilegrid`$windows.data.curatedtilecollection.tilecollection\Current" }
		$data = (Get-ItemProperty -Path $key.PSPath -Name "Data").Data[0..25] + ([byte[]](202,50,0,226,44,1,1,0,0))
		Set-ItemProperty -Path $key.PSPath -Name "Data" -Type Binary -Value $data
	}
}

# Unpin all Taskbar icons - Note: This function has no counterpart. You have to pin the icons back manually.
Function UnpinTaskbarIcons {
	Write-Output "Unpinning all Taskbar icons..."
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Name "Favorites" -Type Binary -Value ([byte[]](255))
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Name "FavoritesResolve" -ErrorAction SilentlyContinue
}



##########
# Auxiliary Functions
##########

# Relaunch the script with administrator privileges
Function RequireAdmin {
	If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
		Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -WorkingDirectory $pwd -Verb RunAs
		Exit
	}
}

# Wait for key press
Function WaitForKey {
	Write-Output "`nPress any key to continue..."
	[Console]::ReadKey($true) | Out-Null
}

# Restart computer
Function Restart {
	Write-Output "Restarting..."
	Restart-Computer
}

# enable some the stuff from windows_hardening.cmd 
Function windows_hardening {

#
# Block Office applications from creating child processes
powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids D4F940AB-401B-4EFC-AADC-AD5F3C50688A -AttackSurfaceReductionRules_Actions Enabled
#
# Block Office applications from injecting code into other processes
powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids 75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84 -AttackSurfaceReductionRules_Actions enable
#
# Block Win32 API calls from Office macro
powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids 92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B -AttackSurfaceReductionRules_Actions enable
#
# Block Office applications from creating executable content
powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids 3B576869-A4EC-4529-8536-B80A7769E899 -AttackSurfaceReductionRules_Actions enable
#
# Block execution of potentially obfuscated scripts
powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids 5BEB7EFE-FD9A-4556-801D-275E5FFC04CC -AttackSurfaceReductionRules_Actions Enabled
#
# Block executable content from email client and webmail
powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550 -AttackSurfaceReductionRules_Actions Enabled
#
# Block JavaScript or VBScript from launching downloaded executable content
powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids D3E037E1-3EB8-44C8-A917-57927947596D -AttackSurfaceReductionRules_Actions Enabled
#
# Block executable files from running unless they meet a prevalence, age, or trusted list criteria
powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids 01443614-cd74-433a-b99e-2ecdc07bfc25 -AttackSurfaceReductionRules_Actions Enabled
#
# Use advanced protection against ransomware
powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids C1DB55AB-C21A-4637-BB3F-A12568109D35 -AttackSurfaceReductionRules_Actions Enabled
#
# Block Win32 API calls from Office macro
powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids 92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B -AttackSurfaceReductionRules_Actions Enabled
#
# Block credential stealing from the Windows local security authority subsystem (lsass.exe)
powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids 9E6C4E1F-7D60-472F-BA1A-A39EF669E4B2 -AttackSurfaceReductionRules_Actions Enabled
#
# Block untrusted and unsigned processes that run from USB
powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids B2B3F03D-6A65-4F7B-A9C7-1C7EF74A9BA4 -AttackSurfaceReductionRules_Actions Enabled
#
# Enable Controlled Folder
powershell.exe Set-MpPreference -EnableControlledFolderAccess Enabled
#
# Enable Cloud functionality of Windows Defender
powershell.exe Set-MpPreference -MAPSReporting Advanced
powershell.exe Set-MpPreference -SubmitSamplesConsent Always

powershell.exe Invoke-WebRequest -Uri https://raw.githubusercontent.com/freeload101/SCRIPTS/master/Windows_Batch/ProcessMitigation.xml -OutFile ProcessMitigation.xml
powershell.exe Set-ProcessMitigation -PolicyFilePath ProcessMitigation.xml
del ProcessMitigation.xml

################################################################################################################
# Harden all version of MS Office itself against common malspam attacks
# Disables Macros, enables ProtectedView
# Sources:
# https://decentsecurity.com/block-office-macros/
# ---------------------
reg add "HKCU\Software\Policies\Microsoft\Office\12.0\Publisher\Security" /v vbawarnings /t REG_DWORD /d 4 /f
reg add "HKCU\Software\Policies\Microsoft\Office\12.0\Word\Security" /v vbawarnings /t REG_DWORD /d 4 /f
reg add "HKCU\Software\Policies\Microsoft\Office\14.0\Publisher\Security" /v vbawarnings /t REG_DWORD /d 4 /f
reg add "HKCU\Software\Policies\Microsoft\Office\14.0\Word\Security" /v vbawarnings /t REG_DWORD /d 4 /f
reg add "HKCU\Software\Policies\Microsoft\Office\15.0\Outlook\Security" /v markinternalasunsafe /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Policies\Microsoft\Office\15.0\Word\Security" /v blockcontentexecutionfrominternet /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Policies\Microsoft\Office\15.0\Excel\Security" /v blockcontentexecutionfrominternet /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Policies\Microsoft\Office\15.0\PowerPoint\Security" /v blockcontentexecutionfrominternet /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Policies\Microsoft\Office\15.0\Word\Security" /v vbawarnings /t REG_DWORD /d 4 /f
reg add "HKCU\Software\Policies\Microsoft\Office\15.0\Publisher\Security" /v vbawarnings /t REG_DWORD /d 4 /f
reg add "HKCU\Software\Policies\Microsoft\Office\16.0\Outlook\Security" /v markinternalasunsafe /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Policies\Microsoft\Office\16.0\Word\Security" /v blockcontentexecutionfrominternet /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Policies\Microsoft\Office\16.0\Excel\Security" /v blockcontentexecutionfrominternet /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Policies\Microsoft\Office\16.0\PowerPoint\Security" /v blockcontentexecutionfrominternet /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Policies\Microsoft\Office\16.0\Word\Security" /v vbawarnings /t REG_DWORD /d 4 /f
reg add "HKCU\Software\Policies\Microsoft\Office\16.0\Publisher\Security" /v vbawarnings /t REG_DWORD /d 4 /f
#
################################################################################################################
# Harden all version of MS Office itself against DDE malspam attacks
# Disables Macros, enables ProtectedView
# Source: https://gist.github.com/wdormann/732bb88d9b5dd5a66c9f1e1498f31a1b
# ---------------------
reg add "HKCU\Software\Microsoft\Office\14.0\Word\Options" /v DontUpdateLinks /t REG_DWORD /d 00000001 /f
reg add "HKCU\Software\Microsoft\Office\14.0\Word\Options\WordMail" /v DontUpdateLinks /t REG_DWORD /d 00000001 /f
reg add "HKCU\Software\Microsoft\Office\15.0\Word\Options" /v DontUpdateLinks /t REG_DWORD /d 00000001 /f
reg add "HKCU\Software\Microsoft\Office\15.0\Word\Options\WordMail" /v DontUpdateLinks /t REG_DWORD /d 00000001 /f
reg add "HKCU\Software\Microsoft\Office\16.0\Word\Options" /v DontUpdateLinks /t REG_DWORD /d 00000001 /f
reg add "HKCU\Software\Microsoft\Office\16.0\Word\Options\WordMail" /v DontUpdateLinks /t REG_DWORD /d 00000001 /f
#
################################################################################################################
# Harden Adobe Acrobat Reader against embeded malicious files - block ALL embeded files
# Sources:
# https://blog.nviso.be/2018/07/26/shortcomings-of-blacklisting-in-adobe-reader-and-what-you-can-do-about-it/
# https://www.adobe.com/devnet-docs/acrobatetk/tools/Wizard/WizardDC/attachments.html
# ---------------------
reg add "HKLM\Software\Policies\Adobe\Acrobat Reader\DC\FeatureLockDown" /v iFileAttachmentPerms /t REG_DWORD /d 00000001 /f




#
# Prevent (remote) DLL Hijacking
# Sources:
# https://www.greyhathacker.net/?p=235
# https://www.verifyit.nl/wp/?p=175464
# https://support.microsoft.com/en-us/help/2264107/a-new-cwdillegalindllsearch-registry-entry-is-available-to-control-the
# The value data can be 0x1, 0x2 or 0xFFFFFFFF. If the value name CWDIllegalInDllSearch does not exist or the value data is 0 then the machine will still be vulnerable to attack.
# Please be aware that the value 0xFFFFFFFF could break certain applications (also blocks dll loading from USB).
# Blocks a DLL Load from the current working directory if the current working directory is set to a WebDAV folder  (set it to 0x1)
# Blocks a DLL Load from the current working directory if the current working directory is set to a remote folder (such as a WebDAV or UNC location) (set it to 0x2)
# ---------------------
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v CWDIllegalInDllSearch /t REG_DWORD /d 0x2 /f
#
# Disable IPv6
# https://support.microsoft.com/en-us/help/929852/guidance-for-configuring-ipv6-in-windows-for-advanced-users
# ---------------------
reg add "HKLM\SYSTEM\CurrentControlSet\services\tcpip6\parameters" /v DisabledComponents /t REG_DWORD /d 0xFF /f
net stop WinRM
wmic /interactive:off nicconfig where TcpipNetbiosOptions=1 call SetTcpipNetbios 2

########################################################################
# Harden lsass to help protect against credential dumping (Mimikatz)
# Configures lsass.exe as a protected process and disables wdigest
# https://technet.microsoft.com/en-us/library/dn408187(v=ws.11).aspx
# https://medium.com/blue-team/preventing-mimikatz-attacks-ed283e7ebdd5
# ---------------------
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\LSASS.exe" /v AuditLevel /t REG_DWORD /d 00000008 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RunAsPPL /t REG_DWORD /d 00000001 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v DisableRestrictedAdmin /t REG_DWORD /d 00000000 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v DisableRestrictedAdminOutboundCreds /t REG_DWORD /d 00000001 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v UseLogonCredential /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" /v Negotiate /t REG_DWORD /d 0 /f
#

#Disable AutoRun
# ---------------------
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 0xff /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v NoDriveTypeAutoRun /t REG_DWORD /d 0xff /f
#
#Show known file extensions and hidden files
# ---------------------
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /t REG_DWORD /d 1 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSuperHidden" /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSuperHidden" /t REG_DWORD /d 1 /f
#


########################################################################
# Uninstall pups
# ---------------------
wmic /interactive:off product where "name like 'Ask Part%' and version like'%'" call uninstall
wmic /interactive:off product where "name like 'searchAssistant%' and version like'%'" call uninstall
wmic /interactive:off product where "name like 'Weatherbug%' and version like'%'" call uninstall
wmic /interactive:off product where "name like 'ShopAtHome%' and version like'%'" call uninstall



}


# remove-default-apps.ps1 
Function remove_default_apps {


Write-Output "Elevating privileges for this process"
do {} until (Elevate-Privileges SeTakeOwnershipPrivilege)

Write-Output "Uninstalling default apps"
$apps = @(
    # default Windows 10 apps
    "Microsoft.3DBuilder"
    "Microsoft.Appconnector"
    "Microsoft.BingFinance"
    "Microsoft.BingNews"
    "Microsoft.BingSports"
    "Microsoft.BingTranslator"
    "Microsoft.BingWeather"
    "Microsoft.FreshPaint"
    "Microsoft.GamingServices"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftPowerBIForWindows"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MicrosoftStickyNotes"
    "Microsoft.MinecraftUWP"
    "Microsoft.NetworkSpeedTest"
    "Microsoft.Office.OneNote"
    "Microsoft.People"
    "Microsoft.Print3D"
    "Microsoft.SkypeApp"
    "Microsoft.Wallet"
    "Microsoft.Windows.Photos"
    "Microsoft.WindowsAlarms"
    #"Microsoft.WindowsCalculator"
    "Microsoft.WindowsCamera"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsPhone"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.WindowsStore"   # can't be re-installed
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"

    # Threshold 2 apps
    "Microsoft.CommsPhone"
    "Microsoft.ConnectivityStore"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
    "Microsoft.WindowsFeedbackHub"

    # Creators Update apps
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MSPaint"

    #Redstone apps
    "Microsoft.BingFoodAndDrink"
    "Microsoft.BingHealthAndFitness"
    "Microsoft.BingTravel"
    "Microsoft.WindowsReadingList"

    # Redstone 5 apps
    "Microsoft.MixedReality.Portal"
    "Microsoft.ScreenSketch"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.YourPhone"

    # non-Microsoft
    "2FE3CB00.PicsArt-PhotoStudio"
    "46928bounde.EclipseManager"
    "4DF9E0F8.Netflix"
    "613EBCEA.PolarrPhotoEditorAcademicEdition"
    "6Wunderkinder.Wunderlist"
    "7EE7776C.LinkedInforWindows"
    "89006A2E.AutodeskSketchBook"
    "9E2F88E3.Twitter"
    "A278AB0D.DisneyMagicKingdoms"
    "A278AB0D.MarchofEmpires"
    "ActiproSoftwareLLC.562882FEEB491" # next one is for the Code Writer from Actipro Software LLC
    "CAF9E577.Plex"  
    "ClearChannelRadioDigital.iHeartRadio"
    "D52A8D61.FarmVille2CountryEscape"
    "D5EA27B7.Duolingo-LearnLanguagesforFree"
    "DB6EA5DB.CyberLinkMediaSuiteEssentials"
    "DolbyLaboratories.DolbyAccess"
    "DolbyLaboratories.DolbyAccess"
    "Drawboard.DrawboardPDF"
    "Facebook.Facebook"
    "Fitbit.FitbitCoach"
    "Flipboard.Flipboard"
    "GAMELOFTSA.Asphalt8Airborne"
    "KeeperSecurityInc.Keeper"
    "NORDCURRENT.COOKINGFEVER"
    "PandoraMediaInc.29680B314EFC2"
    "Playtika.CaesarsSlotsFreeCasino"
    "ShazamEntertainmentLtd.Shazam"
    "SlingTVLLC.SlingTV"
    "SpotifyAB.SpotifyMusic"
    "TheNewYorkTimes.NYTCrossword"
    "ThumbmunkeysLtd.PhototasticCollage"
    "TuneIn.TuneInRadio"
    "WinZipComputing.WinZipUniversal"
    "XINGAG.XING"
    "flaregamesGmbH.RoyalRevolt2"
    "king.com.*"
    "king.com.BubbleWitch3Saga"
    "king.com.CandyCrushSaga"
    "king.com.CandyCrushSodaSaga"

    # apps which cannot be removed using Remove-AppxPackage
    #"Microsoft.BioEnrollment"
    #"Microsoft.MicrosoftEdge"
    #"Microsoft.Windows.Cortana"
    #"Microsoft.WindowsFeedback"
    #"Microsoft.XboxGameCallableUI"
    #"Microsoft.XboxIdentityProvider"
    #"Windows.ContactSupport"

    # apps which other apps depend on
    "Microsoft.Advertising.Xaml"
)

foreach ($app in $apps) {
    Write-Output "Trying to remove $app"

    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers

    Get-AppXProvisionedPackage -Online |
        Where-Object DisplayName -EQ $app |
        Remove-AppxProvisionedPackage -Online
}

# Prevents Apps from re-installing
$cdm = @(
    "ContentDeliveryAllowed"
    "FeatureManagementEnabled"
    "OemPreInstalledAppsEnabled"
    "PreInstalledAppsEnabled"
    "PreInstalledAppsEverEnabled"
    "SilentInstalledAppsEnabled"
    "SubscribedContent-314559Enabled"
    "SubscribedContent-338387Enabled"
    "SubscribedContent-338388Enabled"
    "SubscribedContent-338389Enabled"
    "SubscribedContent-338393Enabled"
    "SubscribedContentEnabled"
    "SystemPaneSuggestionsEnabled"
)

New-FolderForced -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
foreach ($key in $cdm) {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" $key 0
}

New-FolderForced -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" "AutoDownload" 2

# Prevents "Suggested Applications" returning
New-FolderForced -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1

}



# RemoveW10Bloat_2_0.bat Ported to ps1

Function RemoveW10Bloat {
	Write-Output "Restarting..."
	
	Write-Output "Disable Some Service"

sc stop DiagTrack
sc stop diagnosticshub.standardcollector.service
sc stop dmwappushservice
sc stop WMPNetworkSvc
sc stop WSearch

sc config DiagTrack start= disabled
sc config diagnosticshub.standardcollector.service start= disabled
sc config dmwappushservice start= disabled
# sc config RemoteRegistry start= disabled
# sc config TrkWks start= disabled
sc config WMPNetworkSvc start= disabled
sc config WSearch start= disabled
# sc config SysMain start= disabled

# *** SCHEDULED TASKS tweaks ***
# schtasks /Change /TN "Microsoft\Windows\AppID\SmartScreenSpecific" /Disable
schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable
schtasks /Change /TN "Microsoft\Windows\Application Experience\ProgramDataUpdater" /Disable
schtasks /Change /TN "Microsoft\Windows\Application Experience\StartupAppTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /Disable
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Uploader" /Disable
schtasks /Change /TN "Microsoft\Windows\Shell\FamilySafetyUpload" /Disable
schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentLogOn" /Disable
schtasks /Change /TN "Microsoft\Office\OfficeTelemetryAgentFallBack" /Disable
schtasks /Change /TN "Microsoft\Office\Office 15 Subscription Heartbeat" /Disable

schtasks /Change /TN "Microsoft\Windows\Autochk\Proxy" /Disable
schtasks /Change /TN "Microsoft\Windows\CloudExperienceHost\CreateObjectTask" /Disable
schtasks /Change /TN "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Disable
schtasks /Change /TN "Microsoft\Windows\DiskFootprint\Diagnostics" /Disable *** Not sure if should be disabled, maybe related to S.M.A.R.T.
schtasks /Change /TN "Microsoft\Windows\FileHistory\File History (maintenance mode)" /Disable
schtasks /Change /TN "Microsoft\Windows\Maintenance\WinSAT" /Disable
schtasks /Change /TN "Microsoft\Windows\NetTrace\GatherNetworkInfo" /Disable
schtasks /Change /TN "Microsoft\Windows\PI\Sqm-Tasks" /Disable
# schtasks /Change /TN "Microsoft\Windows\Time Synchronization\ForceSynchronizeTime" /Disable
# schtasks /Change /TN "Microsoft\Windows\Time Synchronization\SynchronizeTime" /Disable
schtasks /Change /TN "Microsoft\Windows\Windows Error Reporting\QueueReporting" /Disable
schtasks /Change /TN "Microsoft\Windows\WindowsUpdate\Automatic App Update" /Disable

# *** Remove Cortana ***
# Currently MS doesn't allow to uninstall Cortana using the above step claiming it's a required OS component (hah!)
# We will have to rename the Cortana App folder (add ".bak" to its name), but this can be done only if Cortana is not running.
# The issue is that when Cortana process (SearchUI) is killed, it respawns very quickly
# So the following code needs to be quick (and it is) so we can manage to rename the folder
# Disabling Cortana this way on Version 1703 (RS2) will render all items in the Start Menu unavailable.
# So this is commented out for now until a better solution is found.
# taskkill /F /IM SearchUI.exe
# move "%windir%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy" "%windir%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy.bak"

#  *** Remove Telemetry & Data Collection ***
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /v PreventDeviceMetadataFromNetwork /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v DontOfferThroughWUAU /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /v "CEIPEnable" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\AutoLogger\SQMLogger" /v "Start" /t REG_DWORD /d 0 /f

#  Settings -> Privacy -> General -> Let apps use my advertising ID...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f
# - SmartScreen Filter for Store Apps: Disable
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v EnableWebContentEvaluation /t REG_DWORD /d 0 /f
# - Let websites provide locally...
reg add "HKCU\Control Panel\International\User Profile" /v HttpAcceptLanguageOptOut /t REG_DWORD /d 1 /f

#  WiFi Sense: HotSpot Sharing: Disable
reg add "HKLM\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting" /v value /t REG_DWORD /d 0 /f
#  WiFi Sense: Shared HotSpot Auto-Connect: Disable
reg add "HKLM\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots" /v value /t REG_DWORD /d 0 /f

#  Change Windows Updates to "Notify to schedule restart"
reg add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v UxOption /t REG_DWORD /d 1 /f
#  Disable P2P Update downlods outside of local network
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v DODownloadMode /t REG_DWORD /d 0 /f

#  *** Disable Cortana & Telemetry ***
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f

# *** Hide the search box from taskbar. You can still search by pressing the Win key and start typing what you're looking for ***
# 0 = hide completely, 1 = show only icon, 2 = show long search box
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 0 /f

# *** Disable MRU lists (jump lists) of XAML apps in Start Menu ***
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackDocs" /t REG_DWORD /d 0 /f

# *** Set Windows Explorer to start on This PC instead of Quick Access ***
# 1 = This PC, 2 = Quick access
# reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t REG_DWORD /d 1 /f

# *** Disable Suggestions in the Start Menu ***
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /t REG_DWORD /d 0 /f 

#  Remove Apps
PowerShell -Command "Get-AppxPackage *3DBuilder* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *Cortana* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *Getstarted* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *WindowsAlarms* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *WindowsCamera* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *bing* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *MicrosoftOfficeHub* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *OneNote* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *people* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *WindowsPhone* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *photos* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *SkypeApp* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *solit* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *WindowsSoundRecorder* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *xbox* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *windowscommunicationsapps* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *zune* | Remove-AppxPackage"
# PowerShell -Command "Get-AppxPackage *WindowsCalculator* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *WindowsMaps* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *Sway* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *CommsPhone* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *ConnectivityStore* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *Microsoft.Messaging* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *ContentDeliveryManager* | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage *Microsoft.WindowsStore* | Remove-AppxPackage"


#  NOW JUST SOME TWEAKS
# *** Show hidden files in Explorer ***
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /t REG_DWORD /d 1 /f
 
# *** Show super hidden system files in Explorer ***
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSuperHidden" /t REG_DWORD /d 1 /f

# *** Show file extensions in Explorer ***
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t  REG_DWORD /d 0 /f



# *** Uninstall OneDrive ***
start /wait "" "%SYSTEMROOT%\SYSWOW64\ONEDRIVESETUP.EXE" /UNINSTALL
rd C:\OneDriveTemp /Q /S >NUL 2>&1
rd "%USERPROFILE%\OneDrive" /Q /S >NUL 2>&1
rd "%LOCALAPPDATA%\Microsoft\OneDrive" /Q /S >NUL 2>&1
rd "%PROGRAMDATA%\Microsoft OneDrive" /Q /S >NUL 2>&1
reg add "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /f /v Attributes /t REG_DWORD /d 0 >NUL 2>&1
reg add "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}\ShellFolder" /f /v Attributes /t REG_DWORD /d 0 >NUL 2>&1
echo OneDrive has been removed. Windows Explorer needs to be restarted.



:: https://gist.github.com/Carm01/3b83d78a0d99cc78ff1d46385ba68a13

:: https://gist.github.com/Carm01/3b83d78a0d99cc78ff1d46385ba68a13
:: remove OneDrive icon from quick access file explorer
REG ADD "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v "System.IsPinnedToNameSpaceTree" /d 0 /t REG_DWORD /f
:: set time zone to eastern
REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /v "TimeZoneKeyName" /d "Eastern Standard Time" /t REG_SZ /f
:: disable UAC 
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /d 0 /t REG_DWORD /f




:: Disable update and restart
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoRebootWithLoggedOnUsers" /d 1 /t REG_DWORD /f
:: Disable Wake and install updates
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "AUPowerManagement" /d 0 /t REG_DWORD /f
:: Disable Update and Restart and Update and Shutdown option on power menu
:: https://www.kapilarya.com/how-to-disable-remove-update-and-shut-down-in-windows-10
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAUShutdownOption" /d 1 /t REG_DWORD /f
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAUAsDefaultShutdownOption" /d 1 /t REG_DWORD /f
::  Remove Lock in Account Picture Menu in Windows 10 but allows WINKEY + L
:: https://www.tenforums.com/tutorials/61721-add-remove-lock-account-picture-menu-windows-10-a.html
REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" /v "ShowLockOption"  /d 0 /t REG_DWORD /f



:: turn off game-bar Globally(see below)
:: https://www.top-password.com/blog/disable-game-bar-and-game-dvr-in-windows-10/
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowgameDVR" /d 0 /t REG_DWORD /f
:: Prevent EDGE first run page
REG ADD "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /v "PreventFirstRunPage" /d 1 /t REG_DWORD /f
:: Disable first login Animations
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "EnableFirstLogonAnimation" /d 0 /t REG_DWORD /f

:: Remove People icon from system tray
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" /v "PeopleBand" /d 0 /t REG_DWORD /f
:: Disallow WebSearch in search bar
:: https://www.addictivetips.com/windows-tips/disable-web-search-windows-10-april-update/
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /d 0 /t REG_DWORD /f
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Search" /v "AllowSearchToUseLocation" /d 0 /t REG_DWORD /f
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Search" /v "CortanaConsent" /d 0 /t REG_DWORD /f
:: additional disable cortana
REG ADD "HKEY_CURRENT_USER\DefaultUser\SOFTWARE\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /d 0 /t REG_DWORD /f
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Search" /v "RestrictImplicitTextCollection" /d 1 /t REG_DWORD /f
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Search" /v "RestrictImplicitInkCollection" /d 1 /t REG_DWORD /f
REG ADD "HKEY_CURRENT_USER\DefaultUser\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /d 0 /t REG_DWORD /f
:: Show hidden files
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /d 1 /t REG_DWORD /f
:: Show Show File extensions
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /d 0 /t REG_DWORD /f
:: Show Protected Operating System Files and folders
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSuperHidden" /d 1 /t REG_DWORD /f



::  Set IE HomePage
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\Internet Explorer\Main" /v "Start Page" /d "https://eu.startpage.com/do/mypage.pl?prfe=36c84513558a2d34bf0d89ea505333ad92934a7f254bccb70c1c89932309a9bc818f1bb4bea737976c85d1fa017f7a45" /t REG_SZ /f
:: Disable Sync Provider Notifications
REG ADD "HKEY_CURRENT_USER\DefaultUser\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSyncProviderNotifications" /d 0 /t REG_DWORD /f
:: Turn Off App Suggestions on Start in Windows 10 aka Disable Start Menu App Suggestions
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SystemPaneSuggestionsEnabled" /d 0 /t REG_DWORD /f
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338388Enabled" /d 0 /t REG_DWORD /f
:: Disable Silent App Installation
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SilentInstalledAppsEnabled" /d 0 /t REG_DWORD /f
:: Turn off "Get tips, tricks and suggestions as you use Windows"
:: WARNING! THIS WILL BREAK WINDOWS SPOTLIGHT LEAVE SET TO 1 IF YOU WANT SPOTLIGHT TO WORK. setting Disabled by default
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SoftLandingEnabled" /d 0 /t REG_DWORD /f
:: Prevent “welcome to the best windows ever”
REG ADD "HKEY_CURRENT_USER\DefaultUser\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /d 0 /t REG_DWORD /f
:: Disable “This App is Preventing Shutdown or Restart” Screen 
reg add "HKCU\Control Panel\Desktop" /v "AutoEndTasks" /t REG_SZ /d "1" /f
reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d "1000" /f
reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "1000" /f
reg add "HKLM\System\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t REG_SZ /d "1000" /f

:: Disable Gamebar per user basis
:: https://www.top-password.com/blog/disable-game-bar-and-game-dvr-in-windows-10/
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled"  /d 0 /t REG_DWORD /f
:: Gaming Disable background recording
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\Windows\CurrentVersion\GameDVR" /v "HistoricalCaptureEnabled"  /d 0 /t REG_DWORD /f
:: https://www.tenforums.com/tutorials/76094-turn-off-game-bar-tips-windows-10-a.html
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\GameBar" /v "ShowStartupPanel"  /d 0 /t REG_SZ /f
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\GameBar" /v "AutoGameModeEnabled"  /d 0 /t REG_SZ /f
:: https://www.windowscentral.com/how-disable-and-remove-game-bar-windows-10-creators-update
REG ADD "HKEY_CURRENT_USER\DefaultUser\SYSTEM\CurrentControlSet\Services\xbgm" /v "Start" /d 4 /t REG_SZ /f
:: Show More Details in File Transfer Dialog
REG ADD "HKEY_CURRENT_USER\DefaultUser\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager" /v "EnthusiastMode" /d 1 /t REG_DWORD /f
:: Enable/USE Dark Theme 
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /d 0 /t REG_DWORD /f


:: June 6 2019 - Disable "Restore previous folder windows at logon" 
:: NOTE THIS REGEDIT NORMALLY DOES NOT EXIST. THIS SHOULD NOT HARM ANYTHING IF IT DOES NOT.
REG delete "HKEY_CURRENT_USER\DefaultUser\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "PersistBrowsers" /f


:: Turn Off Automatically Restart Apps After Sign-In
:: May 28th 2020 https://winaero.com/blog/turn-off-automatically-restart-apps-after-sign-in-windows-10/
REG ADD "HKEY_CURRENT_USER\DefaultUser\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "RestartApps" /d 0 /t REG_DWORD /f
:: disable 'Get even more out of Windows' reg value does not normally exist so deleting it is default
REG ADD "HKEY_CURRENT_USER\DefaultUser\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" /v "ScoobeSystemSettingEnabled" /d 0 /t REG_DWORD /f







}


##########
# Parse parameters and apply tweaks
##########






# Normalize path to preset file
$preset = ""
$PSCommandArgs = $args
If ($args -And $args[0].ToLower() -eq "-preset") {
	$preset = Resolve-Path $($args | Select-Object -Skip 1)
	$PSCommandArgs = "-preset `"$preset`""
}

# Load function names from command line arguments or a preset file
If ($args) {
	$tweaks = $args
	If ($preset) {
		$tweaks = Get-Content $preset -ErrorAction Stop | ForEach { $_.Trim() } | Where { $_ -ne "" -and $_[0] -ne "#" }
	}
}

# Call the desired tweak functions
$tweaks | ForEach { Invoke-Expression $_ }


# Enable or Disable "Show more options" context menu using Command
# hack for regedit as trusted installer :P 
sc stop "TrustedInstaller"    
sc config TrustedInstaller binPath= "cmd /c reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve" 1>> output.log 2>&1
sc start "TrustedInstaller"   1>> output.log 2>&1
sc stop "TrustedInstaller"  
  
sc config TrustedInstaller binPath= "cmd /c reg add "HKLM\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve" 1>> output.log 2>&1
sc start "TrustedInstaller"   1>> output.log 2>&1
sc stop "TrustedInstaller" 

sc config TrustedInstaller binPath= "C:\Windows\servicing\TrustedInstaller.exe"   1>> output.log 2>&1
sc config TrustedInstaller binPath= "C:\Windows\servicing\TrustedInstaller.exe"  1>> output.log 2>&1



