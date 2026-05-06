$ConnectQuery = "SELECT * FROM __InstanceCreationEvent WITHIN 2 WHERE TargetInstance ISA 'Win32_PnPEntity'"
$DisconnectQuery = "SELECT * FROM __InstanceDeletionEvent WITHIN 2 WHERE TargetInstance ISA 'Win32_PnPEntity'"

# Clear any previous failed attempts
Get-EventSubscriber | Unregister-Event -ErrorAction SilentlyContinue

Register-WmiEvent -Query $ConnectQuery -SourceIdentifier "USB_In" -Action {
    $Name = $EventArgs.NewEvent.TargetInstance.Name
    Write-Host "$(Get-Date -Format 'HH:mm:ss') - CONNECTED: $Name" -ForegroundColor Green
}

Register-WmiEvent -Query $DisconnectQuery -SourceIdentifier "USB_Out" -Action {
    $Name = $EventArgs.NewEvent.TargetInstance.Name
    Write-Host "$(Get-Date -Format 'HH:mm:ss') - DISCONNECTED: $Name" -ForegroundColor Red
}

Write-Host "Monitoring... If you hear the chime, check here for the device name." -Cyan
while($true) { Start-Sleep -Seconds 1 }
