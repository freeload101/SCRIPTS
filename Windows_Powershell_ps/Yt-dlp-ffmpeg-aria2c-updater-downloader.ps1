if (-not (Test-Path "C:\Windows\SysWOW64\msvcr100.dll")) {
    if (-not (Test-Path "C:\Windows\System32\msvcr100.dll")) {
        Write-Host "$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt') INFO: Downloading Missing msvcr100.dll from 'https://download.microsoft.com/download/C/6/D/C6D0FD4E-9E53-4897-9B91-836EBA2AACD3/vcredist_x86.exe'"

        $url = "https://download.microsoft.com/download/C/6/D/C6D0FD4E-9E53-4897-9B91-836EBA2AACD3/vcredist_x86.exe"
        $output = ".\vcredist_x86.exe"

        (New-Object Net.WebClient).DownloadFile($url, $output)
        Start-Process $output -ArgumentList "/q", "/norestart" -Wait -WindowStyle Hidden
    }
}


Write-Host "$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt') INFO: Opening list.txt save/close notepad with the list of URLs you want downloaded! Use Chrome plugin 'Bulk Media Downloader' to get video URLS if needed"
Start-Sleep -Seconds 1
    Start-Process -FilePath "cmd" -ArgumentList "/c", "notepad list.txt" -wait

# wget
if (-not (Test-Path ".\wget.exe")) {
    Write-Host "$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt') INFO: Downloading wget via Powershell https://eternallybored.org/misc/wget/1.20.3/64/wget.exe (Warning: May NOT be latest binary !)"
    (New-Object Net.WebClient).DownloadFile('https://eternallybored.org/misc/wget/1.20.3/64/wget.exe', '.\wget.exe')
} else {
    Write-Host "$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt') INFO: wget.exe already exists in current directory"
}


# latest aria2
if (-not (Test-Path ".\aria2c.exe")) {
    $latestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/aria2/aria2/releases/latest"
    $win64Asset = $latestRelease.assets | Where-Object { $_.name -like "*win-64bit-build*.zip" }

    if ($win64Asset) {
        Write-Host "$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt') INFO: Downloading $($win64Asset.name)"

        $zipPath = ".\$($win64Asset.name)"
        (New-Object Net.WebClient).DownloadFile($win64Asset.browser_download_url, $zipPath)

        $extractPath = ".\aria2_temp"
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

        $aria2cPath = Get-ChildItem -Path $extractPath -Name "aria2c.exe" -Recurse | Select-Object -First 1

        if ($aria2cPath) {
            Copy-Item -Path (Join-Path $extractPath $aria2cPath) -Destination ".\aria2c.exe" -Force
            Write-Host "$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt') INFO: aria2c.exe copied to current directory"
        }

        Remove-Item -Path $zipPath, $extractPath -Recurse -Force
    } else {
        Write-Host "$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt') ERROR: win-64bit-build zip not found in latest release"
    }
} else {
    Write-Host "$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt') INFO: aria2c.exe already exists in current directory"
}



# yt-dlp
if (Test-Path ".\yt-dlp.exe") {
    Write-Host "$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt') INFO: Updating existing yt-dlp.exe"
    .\yt-dlp.exe -U
} else {
    Write-Host "$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt') INFO: Downloading yt-dlp.exe from https://github.com/yt-dlp/yt-dlp/releases/download/2025.09.05/yt-dlp.exe"
    (New-Object Net.WebClient).DownloadFile('https://github.com/yt-dlp/yt-dlp/releases/download/2025.09.05/yt-dlp.exe', '.\yt-dlp.exe')
}





# gogogo

$urls = Get-Content "list.txt"

foreach ($url in $urls) {
    $UUID = Get-Random

    Write-Host "$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt') INFO: `"$url`" Downloading with aria2c"

    $outputTemplate = ".\downloads\%(uploader)s - %(title)s - %(id)s_$UUID.%(ext)s"
    $aria2cArgs = "--external-downloader aria2c --external-downloader-args `" -x 16 -s 16 -k 1M`""

    Start-Process -FilePath "cmd" -ArgumentList "/c", "yt-dlp.exe -w --no-continue --merge-output-format mkv --ffmpeg-location .\ -o `"$outputTemplate`" -i $aria2cArgs `"$url`" & pause" -WindowStyle Normal

    Write-Host "$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt') INFO: `"$url`" Press Y to skip $env:WAITTIME second wait"

    $timeout = if ($env:WAITTIME) { [int]$env:WAITTIME } else { 30 }
    Start-Sleep -Seconds $timeout

    $downloadFiles = Get-ChildItem -Path ".\downloads" -Name "*$UUID*" -ErrorAction SilentlyContinue

    if (-not $downloadFiles) {
        Write-Host "$(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt') ERROR: `"$url`" No part files found trying legacy mode"
        Start-Process -FilePath "cmd" -ArgumentList "/c", "yt-dlp.exe -w --no-continue --merge-output-format mkv --ffmpeg-location .\ -o `"$outputTemplate`" `"$url`" & pause" -WindowStyle Normal
    }
}


