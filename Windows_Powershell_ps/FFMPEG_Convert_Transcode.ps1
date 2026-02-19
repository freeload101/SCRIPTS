$windowsApps = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
$ffmpegPath = Join-Path $windowsApps "ffmpeg.exe"

if (-not (Test-Path $ffmpegPath)) {
    Write-Host "$(Get-Date) INFO: ffmpeg not found in WindowsApps, downloading latest ffmpeg"

    function downloadFile($url, $file) {
        $req = [System.Net.HttpWebRequest]::Create($url)
        $res = $req.GetResponse().GetResponseStream()
        $fs = [System.IO.FileStream]::new($file, 'Create')
        $buf = [byte[]]::new(10KB)
        while (($c = $res.Read($buf, 0, $buf.Length)) -gt 0) {
            $fs.Write($buf, 0, $c)
        }
    }

    $release = Invoke-WebRequest https://api.github.com/repos/BtbN/FFmpeg-Builds/releases/latest | ConvertFrom-Json
    $asset = $release.assets | Where-Object { $_.name -match "ffmpeg-n.*win64-gpl-[0-9]" } | Select-Object -First 1
    $url = $asset.browser_download_url

    $zipFile = Join-Path $env:TEMP "ffmpeg.zip"
    downloadFile $url $zipFile

    Expand-Archive $zipFile $windowsApps -Force
    Remove-Item $zipFile

    $foundFfmpeg = Get-ChildItem $windowsApps -Recurse -Filter "ffmpeg.exe" | Select-Object -First 1
    if ($foundFfmpeg) {
        Move-Item $foundFfmpeg.FullName $ffmpegPath -Force
    }

    Write-Host "$(Get-Date) INFO: ffmpeg installed to $ffmpegPath"
} else {
    Write-Host "$(Get-Date) INFO: ffmpeg found at $ffmpegPath"
}

Get-ChildItem -File -Recurse | ForEach-Object {
    & $ffmpegPath -r 5 -i $_.FullName -vcodec libx265 -acodec aac "$($_.BaseName)_enc.mp4"
    & $ffmpegPath -i $_.FullName -acodec libmp3lame -b:a 56k -ac 1 -ar 22050 "$($_.BaseName)_enc.mp3"
}
