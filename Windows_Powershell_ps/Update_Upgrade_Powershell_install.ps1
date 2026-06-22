# 1. Get the latest release information from GitHub
$repo = "PowerShell/PowerShell"
$url = "https://api.github.com/repos/$repo/releases/latest"
$release = Invoke-RestMethod -Uri $url

# 2. Filter for the 64-bit MSI (Windows)
$asset = $release.assets | Where-Object { $_.name -like "*win-x64.msi" } | Select-Object -First 1
$downloadUrl = $asset.browser_download_url
$destPath = Join-Path $env:TEMP $asset.name

# 3. Download the installer silently
Write-Host "Downloading $($asset.name)..." -ForegroundColor Cyan
$ProgressPreference = 'SilentlyContinue' # Speeds up download in PS 5.1
Invoke-WebRequest -Uri $downloadUrl -OutFile $destPath

# 4. Perform the Silent Installation
Write-Host "Installing PowerShell silently..." -ForegroundColor Yellow

$installArgs = @(
    "/i", "`"$destPath`"",
    "/quiet",
    "/norestart",
    "ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1",
    "ENABLE_PSREMOTING=1"
)

# Start the installer and wait for it to finish
$process = Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -PassThru

# 5. Cleanup
if ($process.ExitCode -eq 0) {
    Write-Host "Installation successful! Please restart your terminal." -ForegroundColor Green
    Remove-Item -Path $destPath -Force
} else {
    Write-Host "Installation failed with exit code $($process.ExitCode)" -ForegroundColor Red
}
