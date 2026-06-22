#WIP
@echo off
# DON'T DISABLE CYBERARK AF FIRST .. I THINK IT MADE MY  CPU SYSTEM PROCESS 100% I COULD NOT FIGURE OUT HOW TO STOP IT .. 
echo run this as admin! in safe mode
move "C:\Program Files (x86)\Adobe" "C:\Program Files (x86)\Adobe_BK"
move "C:\Program Files (x86)\Mimecast" "C:\Program Files (x86)\Mimecast_BK"
move "C:\Program Files (x86)\Dameware Remote Everywhere Agent" "C:\Program Files (x86)\Dameware Remote Everywhere Agent_BK"
move "C:\Program Files\Websense" "C:\Program Files\Websense_BK"

move "C:\Program Files (x86)\Dell" "C:\Program Files (x86)\Dell_OLD"
move "C:\WINDOWS\System32\drivers\DellFFDPWmiService.exe" "C:\WINDOWS\System32\drivers\DellFFDPWmiService.exe_OLD"
move "C:\Program Files\CyberArk" "C:\Program Files\CyberArk_OLD"
move "C:\Program Files\LRS\LRS.Migration.Agent" "C:\Program Files\LRS\LRS.Migration.Agent_OLD"


Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Sense" /v Start /t reg_dword /d 4 /f 
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Fppsvc" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CcmExec" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinDefend" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\FPDIAG" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\fpeca" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\FppsvcG" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Tenable Nessus Agent" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\AdobeARMservice" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CcmExec" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WSDLP" /v Start /t reg_dword /d 4 /f


Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DellClientManagementService" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DDVDataCollector" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SupportAssistSvc" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DellRemediation" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dell Insights Agent" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dell Hardware Support" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DellFFDPWmiService" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DDVCollectorSvcApi" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DDVRulesProcessor" /v Start /t reg_dword /d 4 /f

Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LRSDRVX" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LRSPULL" /v Start /t reg_dword /d 4 /f




Computer\



bcdedit /set {default} safeboot network
echo reboot now to go into safemode with networking or press any key to set it back to normal
pause
bcdedit /deletevalue {default} safeboot
echo reboot? or close this window not to reboot
pause
shutdown -r -t 1




# powershell

function Take-Permissions {
    # Developed for PowerShell v4.0
    # Required Admin privileges
    # Links:
    #   http://shrekpoint.blogspot.ru/2012/08/taking-ownership-of-dcom-registry.html
    #   http://www.remkoweijnen.nl/blog/2012/01/16/take-ownership-of-a-registry-key-in-powershell/
    #   https://powertoe.wordpress.com/2010/08/28/controlling-registry-acl-permissions-with-powershell/

    param($rootKey, $key, [System.Security.Principal.SecurityIdentifier]$sid = 'S-1-5-32-545', $recurse = $true)

    switch -regex ($rootKey) {
        'HKCU|HKEY_CURRENT_USER'    { $rootKey = 'CurrentUser' }
        'HKLM|HKEY_LOCAL_MACHINE'   { $rootKey = 'LocalMachine' }
        'HKCR|HKEY_CLASSES_ROOT'    { $rootKey = 'ClassesRoot' }
        'HKCC|HKEY_CURRENT_CONFIG'  { $rootKey = 'CurrentConfig' }
        'HKU|HKEY_USERS'            { $rootKey = 'Users' }
    }

    ### Step 1 - escalate current process's privilege
    # get SeTakeOwnership, SeBackup and SeRestore privileges before executes next lines, script needs Admin privilege
    $import = '[DllImport("ntdll.dll")] public static extern int RtlAdjustPrivilege(ulong a, bool b, bool c, ref bool d);'
    $ntdll = Add-Type -Member $import -Name NtDll -PassThru
    $privileges = @{ SeTakeOwnership = 9; SeBackup =  17; SeRestore = 18 }
    foreach ($i in $privileges.Values) {
        $null = $ntdll::RtlAdjustPrivilege($i, 1, 0, [ref]0)
    }

    function Take-KeyPermissions {
        param($rootKey, $key, $sid, $recurse, $recurseLevel = 0)

        ### Step 2 - get ownerships of key - it works only for current key
        $regKey = [Microsoft.Win32.Registry]::$rootKey.OpenSubKey($key, 'ReadWriteSubTree', 'TakeOwnership')
        $acl = New-Object System.Security.AccessControl.RegistrySecurity
        $acl.SetOwner($sid)
        $regKey.SetAccessControl($acl)

        ### Step 3 - enable inheritance of permissions (not ownership) for current key from parent
        $acl.SetAccessRuleProtection($false, $false)
        $regKey.SetAccessControl($acl)

        ### Step 4 - only for top-level key, change permissions for current key and propagate it for subkeys
        # to enable propagations for subkeys, it needs to execute Steps 2-3 for each subkey (Step 5)
        if ($recurseLevel -eq 0) {
            $regKey = $regKey.OpenSubKey('', 'ReadWriteSubTree', 'ChangePermissions')
            $rule = New-Object System.Security.AccessControl.RegistryAccessRule($sid, 'FullControl', 'ContainerInherit', 'None', 'Allow')
            $acl.ResetAccessRule($rule)
            $regKey.SetAccessControl($acl)
        }

        ### Step 5 - recursively repeat steps 2-5 for subkeys
        if ($recurse) {
            foreach($subKey in $regKey.OpenSubKey('').GetSubKeyNames()) {
                Take-KeyPermissions $rootKey ($key+'\'+$subKey) $sid $recurse ($recurseLevel+1)
            }
        }
    }

    Take-KeyPermissions $rootKey $key $sid $recurse
}

Take-Permissions "HKLM" "SYSTEM\CurrentControlSet\Services\FpECAWfp"
Take-Permissions "HKLM" "SYSTEM\CurrentControlSet\Services\Fppsvc"
Take-Permissions "HKLM" "SYSTEM\CurrentControlSet\Services\fpeca"
Take-Permissions "HKLM" "SYSTEM\CurrentControlSet\Services\vfdrv"

Take-Permissions "HKLM" "SYSTEM\CurrentControlSet\Services\vfnet"
Take-Permissions "HKLM" "SYSTEM\CurrentControlSet\Services\vfpd"


sc stop BluetoothUserService_bdcac
sc stop BrokerInfrastructure
sc stop BTAGService
sc stop bthserv
sc stop lfsvc
sc stop Winmgmt
sc stop CcmExec




# Windows Performance Analyzer High CPU
# wpr.exe -start cpu.verbose && timeout 30 && wpr.exe -stop && timeout 10 && C:\CPUUsage.etl



cd "$env:temp"
$newPath  = ".\ADAudit_$(get-date -f yyyyMMdd_mm).csv"

Get-Service  | Where-Object {$_.Status -EQ “Running”} | Select Name , DisplayName , DependentServices|Export-Csv -NoType -Path $newPath
Start-Sleep -Seconds 1
start $newPath




Set-Variable -Name ErrorActionPreference -Value SilentlyContinue

$countb4 = (Get-Process).Count
 
 
Get-Process   | Where{ !($_.ProcessName -eq "explorer") -and !($_.ProcessName -eq "smss")  -and !($_.ProcessName -eq "conhost")  -and !($_.ProcessName -eq "powershell") -and !($_.ProcessName -eq "smartscreen") -and !($_.ProcessName -eq "sihost")  -and !($_.ProcessName -eq "CSFalconService") -and !($_.ProcessName -eq "CSFalconContainer") -and !($_.ProcessName -eq "SecurityHealthService") -and !($_.ProcessName -eq "SecurityHealthSystray") -and !($_.ProcessName -eq "cmd.exe") -and !($_.ProcessName -eq "explorer") -and !($_.ProcessName -eq "taskmgr") -and !($_.ProcessName -eq "svchost") -and !($_.ProcessName -eq "lsass") -and !($_.ProcessName -eq "dwm") -and !($_.ProcessName -eq "fontdrvhost") -and !($_.ProcessName -eq "ctfmon") -and !($_.ProcessName -eq "tasklist") -and !($_.ProcessName -eq "dllhost") -and !($_.ProcessName -eq "lsaiso") -and !($_.ProcessName -eq "pwsh") -and !($_.ProcessName -eq "powershell_ise") -and !($_.ProcessName -eq "winlogon")  -and !($_.ProcessName -eq "PanGPA")   } | Sort-Object -Unique | foreach { 
write-host "Killing" $_.ProcessName
Start-Sleep -Seconds .5
Stop-Process  $_.Id -Force 
Start-Sleep -Seconds .5
Stop-Process  $_.Id -Force
Start-Sleep -Seconds .5
Stop-Process  $_.Id -Force

}
 

$countafter = (Get-Process).Count
$countkilled = $countb4-$countafter
write-host "Killed $countkilled Processes"

write-host "`DONE`n"
Start-Sleep -Seconds 10





