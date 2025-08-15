# this is WIP BUT NO REBOOT NEEDED AT LEAST ON WINDOWS 11
# I don't know what of this fixed it but  I don't have time to test 

Write-Output "Downloading MSEdgeRedirect"
$downloadUri = ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/rcmaehl/MSEdgeRedirect/releases/latest").assets | Where-Object name -like *.exe ).browser_download_url
Invoke-WebRequest -Uri "$downloadUri" -OutFile "c:\windows\temp\MSEdgeRedirect.exe"
# run this ... "c:\windows\temp\MSEdgeRedirect.exe" /uninstall

Write-Output "downloading https://github.com/AveYo/fox/raw/main/Edge_Removal.bat"
Invoke-WebRequest -Uri "https://github.com/AveYo/fox/raw/main/Edge_Removal.bat" -OutFile "c:\windows\temp\Edge_Removal.bat" 


# idk ... RUN "c:\windows\temp\Edge_Removal.bat" edge 
# I have no idea ...
#  EDGE REMOVED!  -GET-ANOTHER-BROWSER? ENTER: firefox  -REINSTALL? ENTER: edge / webview / xsocial 

# fixes play store
Get-AppxPackage -allusers Microsoft.WindowsStore | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"};wsreset -i;Get-AppxPackage -allusers Microsoft.MicrosoftEdge* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

# allows install of edge or webview IDK
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" -Name "Install{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" -Value 1 -Type DWord -Force

# this reinstalls webviewe 
# download install msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/6d376ab4-4a07-4679-8918-e0dc3c0735c8/MicrosoftEdgeWebView2RuntimeInstallerX64.exe 


