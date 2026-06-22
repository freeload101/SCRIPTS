# Define the source and target directories
$sourceDir = "C:\STLAUNCHER\alltalk_tts\outputs"
$targetDir = "C:\STLAUNCHER\alltalk_tts\outputs_merged"
$mergedFileName = "merged_output.wav"
$finalMP3Name = "final_output.mp3"

# Create target directory if it doesn't exist
if (-not (Test-Path -Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir
}

# Get all .wav files sorted by creation time
$wavFiles = Get-ChildItem -Path $sourceDir -Filter *.wav | Sort-Object CreationTime

# Generate a temporary file list for ffmpeg
$tempFileList = Join-Path $sourceDir "filelist.txt"
$wavFiles | ForEach-Object { "file '$($_.FullName)'" } | Set-Content $tempFileList

# Build the ffmpeg command to concatenate the files
$ffmpegConcatCmd = "ffmpeg -f concat -safe 0 -i `"$tempFileList`" -c copy `"$($targetDir + '\' + $mergedFileName)`""

# Execute the ffmpeg command to concatenate
Invoke-Expression $ffmpegConcatCmd

# Build the ffmpeg command to transcode to MP3
$ffmpegTranscodeCmd = "ffmpeg -i `"$($targetDir + '\' + $mergedFileName)`" -acodec libmp3lame -ac 1 -ar 22050 -ab 64k `"$($targetDir + '\' + $finalMP3Name)`""

# Execute the ffmpeg command to transcode
Invoke-Expression $ffmpegTranscodeCmd

# Clean up the temporary file list and intermediate WAV file
Remove-Item $tempFileList
Remove-Item $($targetDir + '\' + $mergedFileName)
