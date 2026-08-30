# Minimize uplay on startup 2026

# 1. Define paths  
$TempDir = [System.IO.Path]::GetTempPath()
$ScriptPath = Join-Path $TempDir "start-uplay.ps1"
$TaskName = "LaunchUplayMinimized"

# 2. The actual script content to write out
$ScriptContent = @'
# Start Ubisoft Connect
Start-Process "C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\upc.exe"

# Wait 5 seconds for the window to appear
Start-Sleep -Seconds 5

# Close the window by its title
Get-Process | Where-Object { $_.MainWindowTitle -eq "Ubisoft Connect" } | ForEach-Object {
    $_.CloseMainWindow()
}
'@

# 3. Write the script to the temp folder
Set-Content -Path $ScriptPath -Value $ScriptContent -Force

# 4. Create the scheduled task components
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$ScriptPath`""
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Highest

# 5. Register the task
Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Principal $Principal -Force

Write-Host "Successfully created script at: $ScriptPath" -ForegroundColor Green
Write-Host "Successfully registered scheduled task: $TaskName" -ForegroundColor Green
