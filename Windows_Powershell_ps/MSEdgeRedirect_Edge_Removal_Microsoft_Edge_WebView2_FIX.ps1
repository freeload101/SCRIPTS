# this is WIP BUT NO REBOOT NEEDED AT LEAST ON WINDOWS 11
# I don't know what of this fixed it but  I don't have time to test 

# fixes play store
Get-AppxPackage -allusers Microsoft.WindowsStore | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"};wsreset -i;Get-AppxPackage -allusers Microsoft.MicrosoftEdge* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

# allows install of edge or webview IDK
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" -Name "Install{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" -Value 1 -Type DWord -Force
 
# Download and silently install WebView2 Runtime
$url = "https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/6d376ab4-4a07-4679-8918-e0dc3c0735c8/MicrosoftEdgeWebView2RuntimeInstallerX64.exe"
$installer = "$env:TEMP\MicrosoftEdgeWebView2RuntimeInstallerX64.exe"

# Download installer
Invoke-WebRequest -Uri $url -OutFile $installer

# Silent install with arguments
Start-Process -FilePath $installer -ArgumentList "/silent /install" -Wait -NoNewWindow

# open play store and install something random
winget install "LinkedIn" --source msstore
