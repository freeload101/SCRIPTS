# 1. Download puttygen.exe (CLI-compatible version)
$puttygenPath = ".\puttygen.exe"
if (-not (Test-Path $puttygenPath)) {
    Write-Host "Downloading puttygen..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://the.earth.li/~sgtatham/putty/latest/w64/puttygen.exe" -OutFile $puttygenPath
}

# 2. Grab all potential key files (excluding existing outputs and tools)
$files = Get-ChildItem -File | Where-Object { $_.Extension -notmatch "ppk|pem|pub|ps1|exe" }

foreach ($file in $files) {
    $src = $file.FullName
    $base = $file.BaseName
    Write-Host "--- Processing: $($file.Name) ---" -ForegroundColor Cyan

    # A. Force OpenSSH PEM (Private) with NO prompt
    # We pipe echo "" to satisfy the "Enter passphrase" prompt automatically
    "" | & ssh-keygen -p -P "" -N "" -m PEM -f "$src" 2>$null
    Copy-Item "$src" "$base.pem" -Force

    # B. Generate OpenSSH Public Key (.pub)
    # We also pipe to this just in case it asks for the original pass
    "" | & ssh-keygen -y -f "$src" > "$base.pub" 2>$null

    # C. Generate PuTTY Private Key (.ppk) for MOBA
    # Using the most basic flags to avoid the -O error
    Start-Process -FilePath $puttygenPath -ArgumentList "`"$src`" --no-passphrase -o `"$base.ppk`"" -Wait -NoNewWindow
}

Write-Host "`nDone! Look for the .pem and .ppk files in this folder." -ForegroundColor Green