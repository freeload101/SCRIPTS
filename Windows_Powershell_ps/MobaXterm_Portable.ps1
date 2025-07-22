# Get the script's directory path
$scriptPath = (Get-Location)
Set-Location -Path "$scriptPath"

# Set environment variables
$env:HOMEDRIVE = Split-Path -Qualifier $scriptPath
$env:APPDATA = Join-Path $scriptPath "Users\Moba_Data\AppData\Roaming"
$env:HOMEPATH = Join-Path $scriptPath "Users\Moba_Data"
$env:LOCALAPPDATA = Join-Path $scriptPath "Users\Moba_Data\AppData\Local"
$env:TEMP = Join-Path $scriptPath "Users\Moba_Data\AppData\Local\Temp"
$env:TMP = Join-Path $scriptPath "Users\Moba_Data\AppData\Local\Temp"
$env:USERPROFILE = Join-Path $scriptPath "Users\Moba_Data"

# Remove the AppData directory and all its contents
$appDataPath = Join-Path $scriptPath "Users\Moba_Data\AppData"
if (Test-Path $appDataPath) {
    Remove-Item -Path $appDataPath -Recurse -Force -ErrorAction SilentlyContinue
}

# Create directory structure
$directories = @(
    $env:USERPROFILE,
    (Join-Path $env:USERPROFILE "AppData"),
    (Join-Path $env:USERPROFILE "AppData\Local"),
    (Join-Path $env:USERPROFILE "AppData\Local\Temp"),
    (Join-Path $env:USERPROFILE "AppData\Roaming")
)

foreach ($dir in $directories) {
    New-Item -ItemType Directory -Path $dir -Force -ErrorAction SilentlyContinue | Out-Null
}


############# downloadFile
function downloadFile($url, $targetFile)
{
    "Downloading $url"
    $uri = New-Object "System.Uri" "$url"
    $request = [System.Net.HttpWebRequest]::Create($uri)
    $request.set_Timeout(15000) #15 second timeout
    $response = $request.GetResponse()
    $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
    $responseStream = $response.GetResponseStream()
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create
    $buffer = new-object byte[] 10KB
    $count = $responseStream.Read($buffer,0,$buffer.length)
    $downloadedBytes = $count
    while ($count -gt 0)
    {
        #[System.Console]::CursorLeft = 0
        #[System.Console]::Write("Downloaded {0}K of {1}K", [System.Math]::Floor($downloadedBytes/1024), $totalLength)
        $targetStream.Write($buffer, 0, $count)
        $count = $responseStream.Read($buffer,0,$buffer.length)
        $downloadedBytes = $downloadedBytes + $count
    }
    "Finished Download"
    $targetStream.Flush()
    $targetStream.Close()
    $targetStream.Dispose()
    $responseStream.Dispose()
}



############# CHECK Moba
Function CheckMoba {
   if (-not(Test-Path -Path "$scriptPath\home" )) {
        try {
			$downloadUri = (Invoke-RestMethod -Method GET -Uri "https://mobaxterm.mobatek.net/download-home-edition.html")    -split '\n' -match '.*_Portable.*zip.*' | ForEach-Object {$_ -ireplace '.* href="','' -ireplace  '".*',''}| select -first 1
     
            downloadFile $downloadUri "$scriptPath\MobaXterm_Portable.zip"

            Expand-Archive -Path "$scriptPath\MobaXterm_Portable.zip" -DestinationPath "."

            $Env:__COMPAT_LAYER='RunAsInvoker'
            Get-ChildItem "$scriptPath\MobaXterm_Personal_*"  | Rename-Item -NewName "MobaXterm_Portable.exe"

            Start-Process -FilePath "$scriptPath\MobaXterm_Portable.exe"  
			}
                catch {
                    throw $_.Exception.Message
            }

            } else {
            Start-Process -FilePath "$scriptPath\MobaXterm_Portable.exe" 
            }

}
 

CheckMoba