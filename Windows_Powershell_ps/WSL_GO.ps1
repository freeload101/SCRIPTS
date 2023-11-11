#WIP
cd "c:\delete\"

# set current directory
$VARCD = (Get-Location)

Write-Host "`n[+] Current Working Directory $VARCD"
Set-Location -Path "$VARCD"


#############Downloading and installing the app###################
# Enable wsl subsystems for linux (if powershell is ran in admin mode)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

# Set Tls12 protocol to be able to download the wsl application
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Start-Process -FilePath "wsl" -WorkingDirectory "$VARCD" -ArgumentList "  --list --quiet " -wait -NoNewWindow -RedirectStandardOutput "$VARCD\RedirectStandardOutput.txt"
 


Get-Content "$VARCD\RedirectStandardOutput.txt" | ForEach-Object {
$_
}

#| ForEach-Object{
#Write-Host $_ 
#}


#Start-Process -FilePath "wsl" -WorkingDirectory "$VARCD" -ArgumentList " --install" -wait  
