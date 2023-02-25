$VARCD = (Get-Location)
Write-Host "[+] Current Working Directory $VARCD"
Set-Location -Path "$env:userprofile"
$VARCD = "$env:userprofile"

<#
# Download 7zip to extract 
$downloadUri = ((Invoke-WebRequest -UseBasicParsing "https://www.7-zip.org/download.html").links | select  href   | Where-Object href -like 'a/7z*-x64.exe'  | select -first 1).href
Invoke-WebRequest -Uri "https://www.7-zip.org/$downloadUri" -Out "$VARCD\7zip.exe" -Verbose
Start-Process -FilePath "$VARCD\7zip.exe" -WorkingDirectory "$VARCD" -ArgumentList "  /S /D=`"$VARCD\7zip`" " 
#>

# run without admin !
$env:__COMPAT_LAYER="RUNASINVOKER"


if (-not(Test-Path -Path "$VARCD\autohotkey" )) { 
        try {
                Write-Host "[+] Downloading AutoHotkey "
                $downloadUri = ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/Lexikos/AutoHotkey_L/releases/latest").assets | Where-Object name -like *.zip ).browser_download_url
                Invoke-WebRequest -Uri $downloadUri -Out "$VARCD\autohotkey.zip"
                Write-Host "[+] Extracting Autohoykey.zip" 
                Add-Type -AssemblyName System.IO.Compression.FileSystem
                Add-Type -AssemblyName System.IO.Compression
                [System.IO.Compression.ZipFile]::ExtractToDirectory("$VARCD\autohotkey.zip", "$VARCD\autohotkey")
            }
                catch {
                    throw $_.Exception.Message
            }
            }
        else {
            Write-Host "[+] $VARCD\autohotkey already exists"
            }



Write-Host "[+] Download latetst AHK script"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/freeload101/SCRIPTS/master/AutoHotkey/C0ffee Anti Idle v2.ahk" -OutFile  "$VARCD\C0ffee Anti Idle v2.ahk"
Start-Sleep -Seconds 2

# start AHK 
Start-Process -FilePath "$VARCD\autohotkey\AutoHotkey64.exe" -WorkingDirectory "$VARCD" -ArgumentList " `"$VARCD\C0ffee Anti Idle v2.ahk`"  " 
