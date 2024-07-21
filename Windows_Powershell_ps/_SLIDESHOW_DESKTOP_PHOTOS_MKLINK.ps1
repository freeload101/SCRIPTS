# Define source and destination directories
$sourceDir = "C:\Users\internet\My Drive\Pictures\2014-17"
$destDir = "c:\SLIDESHOW"

# Ensure the destination directory exists
if (-Not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir
}

# Get all .jpg files in the source directory and copy them to the destination
Get-ChildItem -Path $sourceDir -Filter *.jpg -Recurse | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $destDir
}

Write-Output "All .jpg files have been copied to c:\SLIDESHOW"