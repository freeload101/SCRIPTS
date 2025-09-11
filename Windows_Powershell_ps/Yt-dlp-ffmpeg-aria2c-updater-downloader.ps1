# Check and install Visual C++ Redistributable if needed
if (-not (Test-Path "C:\Windows\SysWOW64\msvcr100.dll") -and -not (Test-Path "C:\Windows\System32\msvcr100.dll")) {
    Write-Host "$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt') INFO: Downloading msvcr100.dll from Microsoft"
    (New-Object Net.WebClient).DownloadFile("https://download.microsoft.com/download/C/6/D/C6D0FD4E-9E53-4897-9B91-836EBA2AACD3/vcredist_x86.exe", ".\vcredist_x86.exe")
    Start-Process ".\vcredist_x86.exe" -ArgumentList "/q", "/norestart" -Wait -WindowStyle Hidden
}
  
"Paste URLS into this and save it" | Out-File -FilePath "list.txt" -Encoding UTF8
Start-Process -FilePath "cmd" -ArgumentList "/c", "notepad list.txt" -Wait

# Download latest aria2c if missing
if (-not (Test-Path ".\aria2c.exe")) {
    $release = (Invoke-RestMethod "https://api.github.com/repos/aria2/aria2/releases/latest").assets | Where-Object { $_.name -like "*win-64bit-build*.zip" } | Select-Object -First 1
    if ($release) {
        Write-Host "$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt') INFO: Downloading $($release.name)"
        (New-Object Net.WebClient).DownloadFile($release.browser_download_url, ".\temp.zip")
        Expand-Archive ".\temp.zip" ".\temp" -Force
        $aria2c = Get-ChildItem ".\temp" -Name "aria2c.exe" -Recurse | Select-Object -First 1
        if ($aria2c) { Copy-Item ".\temp\$aria2c" ".\aria2c.exe" -Force }
        Remove-Item ".\temp.zip", ".\temp" -Recurse -Force
    } else {
        Write-Host "$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt') ERROR: aria2c download failed"
    }
}

# Download or update yt-dlp
if (Test-Path ".\yt-dlp.exe") {
 .\yt-dlp.exe -U
} else {
    Write-Host "$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt') INFO: Downloading yt-dlp.exe"
    (New-Object Net.WebClient).DownloadFile('https://github.com/yt-dlp/yt-dlp/releases/download/2025.09.05/yt-dlp.exe', '.\yt-dlp.exe')
}
 
if (-not (Test-Path ".\ffmpeg.exe")) {
    function downloadFile($url, $targetFile) {
        $uri = New-Object "System.Uri" "$url"
        $request = [System.Net.HttpWebRequest]::Create($uri)
        $request.set_Timeout(15000)
        $response = $request.GetResponse()
        $responseStream = $response.GetResponseStream()
        $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create
        $buffer = new-object byte[] 10KB
        $count = $responseStream.Read($buffer,0,$buffer.length)
        while ($count -gt 0) {
            $targetStream.Write($buffer, 0, $count)
            $count = $responseStream.Read($buffer,0,$buffer.length)
        }
        $targetStream.Flush()
        $targetStream.Close()
        $targetStream.Dispose()
        $responseStream.Dispose()
    }

    Write-Host "$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt') INFO: Downloading ffmpeg.exe"
    $zip = ".\temp.zip"
    $extract = ".\temp"
    downloadFile "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip" $zip
    Expand-Archive -Path $zip -DestinationPath $extract -Force
    $ffmpeg = Get-ChildItem -Path $extract -Name "ffmpeg.exe" -Recurse | Select-Object -First 1
    Move-Item -Path (Join-Path $extract $ffmpeg) -Destination ".\ffmpeg.exe" -Force
    Remove-Item -Path $zip, $extract -Recurse -Force
}

 
# Process URLs
$timeout = if ($env:WAITTIME) { [int]$env:WAITTIME } else { 30 }
Get-Content "list.txt" | ForEach-Object {
    $uuid = Get-Random
    $template = ".\downloads\%(uploader)s - %(title)s - %(id)s_$uuid.%(ext)s"
    $args = "--external-downloader aria2c --external-downloader-args `" -x 16 -s 16 -k 1M`""

    Start-Process cmd -ArgumentList "/c", "yt-dlp.exe -w --no-continue --merge-output-format mkv --ffmpeg-location .\ -o `"$template`" -i $args `"$_`" & pause" -WindowStyle Normal
    Start-Sleep $timeout

    if (-not (Get-ChildItem ".\downloads" -Name "*$uuid*" -ErrorAction SilentlyContinue)) {
        Write-Host "$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt') ERROR: No files found for `"$_`", trying legacy mode"
        Start-Process cmd -ArgumentList "/c", "yt-dlp.exe -w --no-continue  --ffmpeg-location .\ -o `"$template`" `"$_`" & pause" -WindowStyle Normal
    }
}
