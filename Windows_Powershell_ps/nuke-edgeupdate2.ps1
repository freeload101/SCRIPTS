#  MicrosoftEdgeUpdate — NUCLEAR REMOVAL SCRIPT
#  Run AS ADMINISTRATOR (elevated PowerShell)\
#  Target: Windows 10/11, all users, permanent disable
# ═══════════════════════════════════════════════════════════

$ErrorActionPreference='SilentlyContinue'
Get-Process MicrosoftEdgeUpdate -EA 0|Stop-Process -Force
foreach($s in @('edgeupdate','edgeupdatem','EdgeElevation')){gps $s -ea 0|Stop-Service -Force; Set-Service $s -StartupType Disabled}
$wt=Get-ScheduledTask MicrosoftEdgeUpdate* -EA 0; if($wt){$wt|Unregister-ScheduledTask -Confirm:$false}
foreach($n in @('MicrosoftEdgeUpdateTaskMachineCore','MicrosoftEdgeUpdateTaskMachineUA')){gst $n -EA 0|Unregister-ScheduledTask -Confirm:$false}
$pt=@('MicrosoftEdgeUpdateTaskUserCore','MicrosoftEdgeUpdateTaskUserUA'); Get-CimInstance Win32_UserProfile -EA 0|?{$_.Special -eq $false -and $_.Loaded -eq $false}|%{foreach($tn in $pt){dst $tn -EA 0; ust $tn -Confirm:$false -EA 0}; $hkcu="Registry::HKEY_USERS\$($_.SID)\Software\Microsoft\Windows\CurrentVersion\Run"; Test-Path $hkcu|%{foreach($k in @('MicrosoftEdgeUpdateTaskMachineCore','MicrosoftEdgeUpdateTaskMachineUA')){riip $hkcu -Name $k -EA Stop}}}|Out-Null
$ep="HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate"; if(-not(Test-Path $ep)){ni $ep -Force|Out-Null}; sp $ep AutoUpdate 0 -Type DWord; sp $ep Update 1 -Type DWord
foreach($fl in @("${env:ProgramFiles(x86)}\Microsoft\EdgeUpdate","${env:ProgramFiles}\Microsoft\EdgeUpdate")){if(Test-Path $fl){$acl=Get-Acl $fl; $acl.SetAccessRuleProtection($true,$false); $dr=New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","Modify,Delete,Write,Synchronize","ContainerInherit,ObjectInherit","None","Deny"); $acl.AddAccessRule($dr); Set-Acl $fl -AclObject $acl}}
$td="${env:windir}\System32\Tasks\Microsoft"; if(Test-Path $td){gci $td -Filter "Edge*" -EA 0|Remove-Item -Force}; gci "${env:windir}\System32\Tasks" -Filter "MicrosoftEdgeUpdate*" -EA 0|Remove-Item -Force
