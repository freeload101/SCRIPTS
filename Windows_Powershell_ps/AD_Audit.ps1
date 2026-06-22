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

Get-ADUser -Filter "Enabled -eq '$true'" -Prop LastLogonDate,PasswordNeverExpires,PasswordNotRequired,Enabled,SamAccountName,UserPrincipalName,PasswordLastSet,Department,Description,DisplayName,EmailAddress,LastBadPasswordAttempt,LastKnownParent,ScriptPath,Title,userAccountControl,whenChanged,whenCreated,DistinguishedName,memberof |
#select -First 100| #debug
select LastLogonDate,PasswordNeverExpires,PasswordNotRequired,Enabled,SamAccountName,UserPrincipalName,PasswordLastSet,Department,Description,DisplayName,EmailAddress,LastBadPasswordAttempt,LastKnownParent,ScriptPath,Title,userAccountControl,whenChanged,whenCreated,DistinguishedName,
@{N= "MemberGroups"; E ={(($_.MemberOf).split(",") |
where-object {$_.contains("CN=")}).replace("CN=","")-join "`n"}} |Export-Csv -NoType -Path $newPath
Start-Sleep -Seconds 1
start $newPath
<#

[pscustomobject]@{"MemberOf"=$_ }} 

$_.memberOf -replace '^CN=|\\|,\w\w=.*' -join ', '


#>
