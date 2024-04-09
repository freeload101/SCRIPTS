
Get-ScheduledTask | Where-Object { $_.TaskPath -notmatch 'Microsoft' } | ForEach-Object {
    $taskName = $_.TaskName
    $taskPath = $_.TaskPath
    $description = $_.Description
    $commands = $_.Actions | ForEach-Object { "$($_.Execute) $($_.Arguments)" }
    [PSCustomObject]@{
        TaskName = $taskName
        TaskPath = $taskPath
        Description = $description
        Command = $commands -join "; "
    }
} | Export-Csv -Path "ScheduledTasksDetails.csv" -NoTypeInformation -Encoding UTF8
Start-Sleep -Seconds 3

Invoke-Item ScheduledTasksDetails.csv

$tasksToRemove = @("Adobe", "edge", "onedrive", "google", "SupportAssistAgent", "MECM" )

Get-ScheduledTask | Where-Object { $taskName = $_.TaskName; $tasksToRemove | Where-Object { $taskName -match $_ } } | Unregister-ScheduledTask -Confirm:$false
