# zip file is 'broken' but download works!

$downloadUri = ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/trustcrypto/OnlyKey-App/releases/latest").assets | Where-Object name -like *.exe ).browser_download_url
echo $downloadUri
#Invo1ke-WebRequest -Uri $downloadUri -Out $env:TEMP\Onlykey.zip
#Expand-Archive -Path $env:TEMP\Onlykey.zip -DestinationPath "$env:TEMP\" -Force
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

[System.IO.Compression.ZipFile]::ExtractToDirectory("$env:TEMP\Onlykey.zip", "$env:TEMP")



#explorer "$env:TEMP\Onlykey\"


# 	powershell  -command "& {Add-Type -Assembly "System.IO.Compression.Filesystem"; [System.IO.Compression.ZipFile]::ExtractToDirectory(\"%BASE%BloodHound-win32-x64.zip\",  \"%BASE%\\")  }"	 > %temp%\null
