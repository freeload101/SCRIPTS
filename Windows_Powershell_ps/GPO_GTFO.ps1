$Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-Command "Remove-Item -Path \'HKLM:\SOFTWARE\Policies' -Recurse"'
$Trigger = New-ScheduledTaskTrigger -AtStartup -RepetitionInterval (New-TimeSpan -Seconds 59) -RepetitionDuration (New-TimeSpan -Days (365 * 10))
Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName "GPOGTFO" -Description "Removes GPO policies from registry every 59 seconds after startup"
