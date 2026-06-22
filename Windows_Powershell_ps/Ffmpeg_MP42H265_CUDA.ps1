# check for ffmpeg ...
# Remove network drive Z: if it exists
Remove-PSDrive -Name Z -ErrorAction SilentlyContinue

# Map network drive Z: to the current directory
$drivePath = (Get-Location).Path
New-PSDrive -Name Z -PSProvider FileSystem -Root $drivePath

# Change to drive Z:
Set-Location Z:

# Use ffmpeg to convert all .mp4 files in the directory and its subdirectories
Get-ChildItem -Recurse -Filter *.mp4 | ForEach-Object {
    $inputFile = $_.FullName
    $outputFile = [System.IO.Path]::Combine($_.DirectoryName, "$($_.BaseName)_H265.mp4")
	$cudaQuery = Get-WmiObject Win32_PnPEntity | Where-Object { $_.Name -like "*NVIDIA*" }
		if ($cudaQuery) {
			Write-Output "CUDA is available."
				& ffmpeg.exe -hwaccel cuda -i $inputFile -vcodec libx265 -acodec aac $outputFile
		} else {
			Write-Output "CUDA is not available."
				& ffmpeg.exe -i $inputFile -vcodec libx265 -acodec aac $outputFile
		}	 
}
Pause
