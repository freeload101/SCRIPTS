$windowsApps = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
$ffmpegPath = Join-Path $windowsApps "ffmpeg.exe"

# Set execution policy to allow script execution if needed
try {
    $currentPolicy = Get-ExecutionPolicy
    if ($currentPolicy -eq "Restricted") {
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
        Write-Host "$(Get-Date) INFO: Execution policy changed to Bypass for this process"
    }
} catch {
    Write-Host "$(Get-Date) INFO: Could not change execution policy: $_"
}

if (-not (Test-Path $ffmpegPath)) {
    Write-Host "$(Get-Date) INFO: ffmpeg not found in WindowsApps, downloading latest ffmpeg"
    
    # Use modern download method to avoid security warnings
    $release = Invoke-WebRequest -Uri "https://api.github.com/repos/BtbN/FFmpeg-Builds/releases/latest" -UseBasicParsing | ConvertFrom-Json
    $asset = $release.assets | Where-Object { $_.name -match "ffmpeg-n.*win64-gpl-[0-9]" } | Select-Object -First 1
    $url = $asset.browser_download_url

    $zipFile = Join-Path $env:TEMP "ffmpeg.zip"
    
    # Download using WebClient with proper headers to avoid security warnings
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
        $webClient.DownloadFile($url, $zipFile)
        Write-Host "$(Get-Date) INFO: Downloaded ffmpeg to $zipFile"
    } catch {
        Write-Error "Failed to download ffmpeg: $_"
        exit 1
    }

    Expand-Archive -Path $zipFile -DestinationPath $windowsApps -Force
    Remove-Item $zipFile

    $foundFfmpeg = Get-ChildItem $windowsApps -Recurse -Filter "ffmpeg.exe" | Select-Object -First 1
    if ($foundFfmpeg) {
        Move-Item $foundFfmpeg.FullName $ffmpegPath -Force
    }

    Write-Host "$(Get-Date) INFO: ffmpeg installed to $ffmpegPath"
} else {
    Write-Host "$(Get-Date) INFO: ffmpeg found at $ffmpegPath"
}

# Process all files in current directory (excluding the script itself and already processed files)
Get-ChildItem -File | ForEach-Object {
    $inputFile = $_.FullName
    $fileName = $_.Name
    $baseName = $_.BaseName
    $extension = $_.Extension
    
    # Skip the script file itself and already processed files
    if ($fileName -eq "FFMPEG_Convert_Transcode.ps1" -or $fileName -like "*_enc.*") {
        return
    }
    
    # Check if input file exists before processing
    if (Test-Path $inputFile) {
        Write-Host "$(Get-Date) INFO: Processing $inputFile"
        try {
            # Create unique output names to avoid conflicts
            $outputMp4 = $baseName + "_enc.mp4"
            $outputMp3 = $baseName + "_enc.mp3"
            
            # Check if output files already exist and remove them if they do
            if (Test-Path $outputMp4) {
                Remove-Item $outputMp4 -Force
            }
            if (Test-Path $outputMp3) {
                Remove-Item $outputMp3 -Force
            }
            
            # Transcode to MP4 with H.265 codec (with error handling and overwrite flag)
            & $ffmpegPath -i $inputFile -vcodec libx265 -acodec aac -y $outputMp4
            Write-Host "$(Get-Date) INFO: Created $outputMp4"
        } catch {
            Write-Warning "Failed to encode to MP4: $_"
        }
        
        try {
            # Transcode to MP3 with specified settings
            & $ffmpegPath -i $inputFile -acodec libmp3lame -b:a 56k -ac 1 -ar 22050 -y $outputMp3
            Write-Host "$(Get-Date) INFO: Created $outputMp3"
        } catch {
            Write-Warning "Failed to encode to MP3: $_"
        }
    } else {
        Write-Warning "Input file not found: $inputFile"
    }
}
