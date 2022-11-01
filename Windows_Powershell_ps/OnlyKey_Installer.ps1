$VARCD = (Get-Location)

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
        #[System.Console]::Write("`nDownloaded {0}K of {1}K", [System.Math]::Floor($downloadedBytes/1024), $totalLength)
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

$downloadUri = ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/trustcrypto/OnlyKey-App/releases/latest").assets | Where-Object name -like *Portable*.exe ).browser_download_url
downloadFile "$downloadUri" "$VARCD\OnlyKey_Portable.exe"

<# NOT NEEDED THEY MADE IT PORTABLE ...

$Env:__COMPAT_LAYER='RunAsInvoker'
Start-Process -FilePath  -ArgumentList  " /D=$env:LOCALAPPDATA\Onlykey\  "  #-Wait  -Verbose -WindowStyle Hidden 

start-sleep -Seconds 5
$SendWait = New-Object -ComObject wscript.shell;
$SendWait.SendKeys('{ENTER}')

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

Wait-Process -Name Onlykey -Timeout 300

explorer "$env:LOCALAPPDATA\Onlykey\"

#>

Start-Process -FilePath "$VARCD\OnlyKey_Portable.exe"
