# This script aids in troubleshooting Windows system issues by implementing a white list of required processes and closing unnecessary ones, reducing CPU usage. For advanced assistance, consult the following resources:

# https://github.com/freeload101/CrowdStrike_RTR_Powershell_Scripts/blob/main/srum_dump2.ps1
# https://github.com/freeload101/SCRIPTS/blob/master/Windows_Powershell_ps/WPS_WPR_Windows%20Performance%20Analyzer.ps1
# https://github.com/freeload101/CrowdStrike_RTR_Powershell_Scripts

# safe mode add/remove software 
# REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Minimal\MSIServer" /VE /T REG_SZ /F /D "Service"
# REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Network\MSIServer" /VE /T REG_SZ /F /D "Service"
# net start msiserver


Set-Variable -Name ErrorActionPreference -Value SilentlyContinue

$countb4 = (Get-Process).Count
 
 
Get-Process   | Where{!($_.UserName -match "NT AUTHORITY\\(?:SYSTEM|(?:LOCAL|NETWORK) SERVICE)") -and !($_.ProcessName -eq "explorer") -and !($_.ProcessName -eq "smss")  -and !($_.ProcessName -eq "conhost")  -and !($_.ProcessName -eq "powershell") -and !($_.ProcessName -eq "smartscreen") -and !($_.ProcessName -eq "sihost")  -and !($_.ProcessName -eq "CSFalconService") -and !($_.ProcessName -eq "CSFalconContainer") -and !($_.ProcessName -eq "SecurityHealthService") -and !($_.ProcessName -eq "SecurityHealthSystray") -and !($_.ProcessName -eq "cmd.exe") -and !($_.ProcessName -eq "explorer") -and !($_.ProcessName -eq "taskmgr") -and !($_.ProcessName -eq "svchost") -and !($_.ProcessName -eq "lsass") -and !($_.ProcessName -eq "dwm") -and !($_.ProcessName -eq "fontdrvhost") -and !($_.ProcessName -eq "ctfmon") -and !($_.ProcessName -eq "tasklist") -and !($_.ProcessName -eq "Winlogon") -and !($_.ProcessName -eq "dllhost") -and !($_.ProcessName -eq "lsaiso") -and !($_.ProcessName -eq "pwsh") -and !($_.ProcessName -eq "powershell_ise")  } | select -Unique | foreach { 
write-host "About to kill: "$_.ProcessName
# DEBUG Start-Sleep -Seconds 10
Stop-Process  $_.Id -Force 
}
 
Start-Sleep -Seconds 10

$countafter = (Get-Process).Count
$countkilled = $countb4-$countafter
write-host "Killed $countkilled Processes"



# --- Start of Configuration ---

# Define the list of your approved service name patterns (using regular expressions).
# '.*' is a regex wildcard that matches any sequence of characters.
# Patterns are automatically anchored to match the full service name.
$approvedServicePatterns = @(
    'BrokerInfrastructure', 'DcomLaunch', 'PlugPlay', 'Power', 'SystemEventsBroker',
    'RpcEptMapper', 'RpcSs', 'LSM', 'HvHost', 'TermService', 'lmhosts', 'BthAvctpSvc',
    'NcbService', 'TimeBrokerSvc', 'hidserv', 'nsi', 'netprofm', 'UmRdpService',
    'camsvc', 'CertPropSvc', 'Winmgmt', 'Schedule', 'Dnscache', 'LanmanWorkstation',
    'ProfSvc', 'UserManager', 'SessionEnv', 'Dhcp', 'CoreMessagingRegistrar',
    'WinHttpAutoProxySvc', 'HNS', 'EventLog', 'EventSystem', 'Themes', 'SENS',
    'nvagent', 'AudioEndpointBuilder', 'BFE', 'mpssvc', 'StateRepository',
    'DispBrokerDesktopSvc', 'SharedAccess', 'IKEEXT', 'PolicyAgent', 'Audiosrv',
    'TextInputManagementService', 'DusmSvc', 'Wcmsvc', 'WlanSvc', 'ShellHWDetection',
    'iphlpsvc', 'DeviceAssociationService', 'CryptSvc', 'DPS', 'SstpSvc', 'StiSvc',
    'TapiSrv', 'LanmanServer', 'RasMan', 'StorSvc', 'LicenseManager', 'SSDPSRV',
    'FontCache', 'DeviceInstall', 'webthreatdefsvc', 'InstallService', 'CDPSvc',
    'Appinfo', 'WdiSystemHost', 'UsoSvc', 'wscsvc', 'WpnService', 'RmSvc', 'fdPHost',
    'wcncsvc', 'DsSvc', 'DisplayEnhancementService', 'AppXSvc', 'gpsvc', 'NgcCtnrSvc',
    'TokenBroker', 'wlidsvc', 'ClipSVC', 'XblAuthManager', 'BDESVC', 'wuauserv', 'BITS',
    # Patterns for user-specific services (wildcard '.*' used)
    'CDPUserSvc_.*',
    'webthreatdefusersvc_.*',
    'WpnUserService_.*',
    'cbdhsvc_.*',
    'OneSyncSvc_.*',
    'PimIndexMaintenanceSvc_.*',
    'UnistoreSvc_.*',
    'UserDataSvc_.*',
    'NPSMSvc_.*',
    'DevicesFlowUserSvc_.*',
    'UdkUserSvc_.*'
)

# --- End of Configuration ---

# Combine all patterns into a single regex string.
# The '^' and '$' anchor the match to the beginning and end of the service name,
# ensuring that 'svc' doesn't accidentally match 'myservice'.
$combinedRegex = '^(' + ($approvedServicePatterns -join '|') + ')$'


# Get all svchost.exe processes
$svchostProcesses = Get-CimInstance -ClassName Win32_Process -Filter "Name = 'svchost.exe'"

# Loop through each svchost process
foreach ($process in $svchostProcesses) {
    # Get all services hosted by this specific process
    $hostedServices = Get-CimInstance -ClassName Win32_Service -Filter "ProcessId = $($process.ProcessId)"

    if (-not $hostedServices) {
        continue
    }

    # Find any services whose names DO NOT MATCH the combined regex pattern.
    $unapprovedServices = $hostedServices | Where-Object { $_.Name -notmatch $combinedRegex }

    # If we found at least one unapproved service, terminate the process
    if ($unapprovedServices) {
 
        $unapprovedServices | ForEach-Object {
        Write-Host "About to kill: Service $($_.Name) ($($_.DisplayName))" }
        Stop-Process -Id $process.ProcessId -Force  
    }
}
 

write-host "`DONE`n"
Start-Sleep -Seconds 10




