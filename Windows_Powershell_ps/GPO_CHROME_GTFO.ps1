set-Variable -Name ErrorActionPreference -Value SilentlyContinue

$Action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-Command "Remove-Item -Path HKLM:\SOFTWARE\Policies\Google\Chrome -Recurse -Force"'
$Trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 10) -RepetitionDuration  
Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName "RemoveChromePolicy" -Description "Removes Chrome policy registry key every 10 minutes indefinitely."



Get-ChildItem -Path C:\Users\internet -Recurse -Directory -Filter "Extensions" | ForEach-Object {
    Get-ChildItem -Path $_.FullName
} | Select-Object -Unique -Property Name | ForEach-Object { 
Write-Output $_.Name | Out-String
$ID= $_.Name | Out-String
Start-Process "C:\Users\internet\IronPortable64\IronPortable.exe" -ArgumentList "https://chromewebstore.google.com/search/$ID" 
}


