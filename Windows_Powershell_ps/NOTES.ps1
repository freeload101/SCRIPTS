# example XML parse
(Invoke-RestMethod -Uri 'https://plex.tv/api/users/?X-Plex-Token=_TOKEN_').MediaContainer.User|select Username, Email |ConvertTo-Csv -NoTypeInformation 

# replace in action
$output | -replace '.*username=\"(.*)" email=\"(.*)" recommend.*','$1,$2

# for each  string ?? object?? 
| foreach { -f $_.Email } 

# I don't even know...powershell had a object and I could not for the life of me figure out how to use it .. Enumerate-ObjectProperties does not work anymore but it use to .. 


------------

function Enumerate-ObjectProperties {

  <#
    .SYNOPSIS
        Enumerate Powershell Object Properties
    .PARAMETER TYPE
        Object or String .. hell I have no idea .. GD powershell
    #>
    [CmdletBinding()]
    param (

[psobject] $Object,

[int32] $Depth = 10,

[string] $Root
        )
 
 
 
 # DCOM CLSID
 #Set-Variable -Name ErrorActionPreference -Value SilentlyContinue
 
((gwmi Win32_COMSetting).InprocServer32) | Sort-Object -Unique  | foreach-object {
} | Export-Csv -Path .\WmiData.csv -NoTypeInformation
start  .\WmiData.csv 


 


Write-Output $($Object.PSObject.Properties | Format-Table @{ Label = 'Type'; Expression = { "[$($($_.TypeNameOfValue).Split('.')[-1])]" } }, Name, Value -AutoSize -Wrap | Out-String)



foreach ($Property in $Object.PSObject.Properties) {

# Strings always have a single property "Length". Do not enumerate this.

if (($Property.TypeNameOfValue -ne 'System.String') -and ($($Object.$($Property.Name).PSObject.Properties)) -and ($Level -le $Depth)) {

$NewRoot = $($($Root + '.' + $($Property.Name)).Trim('.'))

$Level++

Write-Output "Property: $($NewRoot) (Level: $Level)"

Enumerate-ObjectProperties -Object $($Object.$($Property.Name)) -Root $NewRoot

$Level--

}

}

}

 

-----------

|Out-String -Stream

Write-Output '---------outputing data ---------------------'
$data| Measure-Object -Line
Write-Output '--------TYPE---------------'
$data.GetType().Name
Write-Output '---------Select-String---------------------'
#$data| Select-String -Pattern '.*adam.*' -AllMatches -List
Write-Output $data| Select-String -Pattern 'adam' -AllMatches  -SimpleMatch

Write-Output '---------CHECK PATTERN---------------------'
$data9| ForEach-Object {
Write-Output "This is an object"
$_ | Select-String -Pattern '.*username.*'
}

Write-Output '--------TYPE---------------'
$data.GetType().BaseType



Write-Output '--------write data---------------'
Write-Output $CONTENT1.length
Write-Output '--------object_properties---------------'

$CONTENT1.RawContent |Select-String -SimpleMatch -Pattern 'adam'  
join ","



Write-Output '--------object_properties---------------'

$data| Get-Member -MemberType Property

foreach($object_properties in $data.PsObject.Properties)
{
    # Access the name of the property
    $object_properties.Name

    # Access the value of the property
    $object_properties.Value
}






###################################################### 

## Wipe existing BitLocker protections
manage-bde -protectors -delete C:
# Create new, randomly generated recovery password 
manage-bde -protectors -add C: -RecoveryPassword
# Verify new recovery password will be required on next reboot
manage-bde -protectors -enable C:
# Force the user to be prompted for new recovery password
manage-bde -forcerecovery C:

#############################################################
####################### WARNING #############################
#############################################################
# YOU MUST COPY THE KEY (PASSWORD) TO UNLOCK THE DRIVE IF YOU LOSE THE KEY YOU WILL NOT BE ABLE TO RECOVER ANYTHING FROM THE C: DRIVE !!!
# EXAMPLE 713438-591129-666237-608498-028864-058685-409024-701756




# force Reboot system to trigger recovery prompt 
Restart-Computer -Force

#########################-
## ubuntu 19.10 enhanced session hyper v


# AFTER Set-VM -VMName <your_vm_name>  -EnhancedSessionTransportType HvSocket 
https://unix.stackexchange.com/questions/571645/hyper-v-enhanced-session-mode-ubuntu-19-10

As a privileged administrator user use your text editor to perform the following changes of the GDM3 custom configuration file /etc/gdm3/custom.conf.
FROM:

#WaylandEnable=false
TO:

WaylandEnable=false
By uncommenting the above line your system will use the Xorg display manager instead of Wayland next time it boots.

Reboot



#################
# Powershell to search all of registry

# Dump registry. Faster than Get-ChildItem/Get-ItemProperty and you can do other searches after
start-Process "regedit"  -ArgumentList "/e c:\output.txt" -Wait

# example regex ( forgot regex hates .*string.* )
Select-String -Path c:\output.txt -Pattern 'MobaXterm.*' -AllMatches  -Context 1, 1

# Search for URLS and IPs 
#Select-String -Path c:\output.txt -Pattern '"\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"','\b(ht|f)tp(s?)[^ ]*\.[^ ]*(\/[^ ]*)*\b' -AllMatches 



# Mass powershell unlock script
# install AD Mod
Add-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 -Online
Install-WindowsFeature -Name “RSAT-AD-PowerShell” -IncludeAllSubFeature
Get-Module -Name ActiveDirectory -ListAvailable

# import mod and unlock all 
Import-Module ActiveDirectory
Search-ADAccount –SearchBase ‘OU=YOUROUNAMEHERE,DC=YOURDOMAINHERE,DC=com’ –LockedOut | Unlock-ADAccount -Passthru



# password not required UF_PASSWD_NOTREQD
# http://www.selfadsi.org/ads-attributes/user-userAccountControl.htm#UF_PASSWD_NOTREQD
#Get-ADUser -Filter {PasswordNotRequired -eq $true} |  Export-Csv -Path .\PasswordNotRequired.csv
Get-ADUser -Filter * -Properties * |  Export-Csv -Path .\ADAudit.csv
start .\ADAudit.csv



# not match ...

$WScript.CreateShortcut($_.FullName).Arguments}| sort -Unique | Select-String -Pattern 'WINDOWS|Teams|program files' -NotMatch 



# Get CPU usage for top 5 process
echo "Computer Name: $env:COMPUTERNAME"
Get-Process | Sort CPU -descending | Select -first 5 -Property ID, ProcessName, Description, CPU 

# better 
foreach($i in 1..10){
Get-Counter '\Process(*)\% Processor Time' | Select-Object -ExpandProperty countersamples| Select-Object -Property instancename, cookedvalue| ? {$_.instanceName -notmatch "^(idle|_total|system)$"} | Sort-Object -Property cookedvalue -Descending | Select-Object -First 10|Out-String
Start-Sleep -Seconds .5
}


# print string backward
-join $CertSubjectHash[-1..-$CertSubjectHash.Length]



# dump AD memberOf
Set-ItemProperty “REGISTRY::HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU” UseWUserver -value 0
Get-Service wuauserv | Restart-Service
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
Add-WindowsCapability -Online -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0
Add-WindowsCapability -online -name Rsat.ServerManager.Tools~~~~0.0.1.0
#DISM.exe /Online /add-capability /CapabilityName:Rsat.CertificateServices.Tools~~~~0.0.1.0
Set-ItemProperty “REGISTRY::HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU” UseWUserver -value 1
Get-Service wuauserv | Restart-Service



cd "$env:temp"
$newPath  = ".\ADAudit_$(get-date -f yyyyMMdd_mm).csv"

Get-ADUser -Filter "Enabled -eq '$true'" -Prop LastLogonDate,PasswordNeverExpires,PasswordNotRequired,Enabled,SamAccountName,UserPrincipalName,PasswordLastSet,Department,Description,DisplayName,EmailAddress,LastBadPasswordAttempt,LastKnownParent,ScriptPath,Title,userAccountControl,whenChanged,whenCreated,memberof |
#DEBUG select -First 10 LastLogonDate,PasswordNeverExpires,PasswordNotRequired,Enabled,SamAccountName,UserPrincipalName,PasswordLastSet,Department,Description,DisplayName,EmailAddress,LastBadPasswordAttempt,LastKnownParent,ScriptPath,Title,userAccountControl,whenChanged,whenCreated, 
select LastLogonDate,PasswordNeverExpires,PasswordNotRequired,Enabled,SamAccountName,UserPrincipalName,PasswordLastSet,Department,Description,DisplayName,EmailAddress,LastBadPasswordAttempt,LastKnownParent,ScriptPath,Title,userAccountControl,whenChanged,whenCreated, 
@{N= "MemberGroups"; E ={(($_.MemberOf).split(",") |
where-object {$_.contains("CN=")}).replace("CN=","")-join "`n"} }|
Export-Csv -NoType -Path $newPath
