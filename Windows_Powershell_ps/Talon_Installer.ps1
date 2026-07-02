function downloadFile($url, $file) {
    $res = [System.Net.HttpWebRequest]::Create($url).GetResponse().GetResponseStream()
    $fs = [System.IO.FileStream]::new($file, 'Create')
    $buf = [byte[]]::new(256KB)
    while (($c = $res.Read($buf, 0, $buf.Length)) -gt 0) { $fs.Write($buf, 0, $c) }
    $fs.Close(); $res.Close()
}

function KillTalon{
Stop-Process -Name talon -Force -ErrorAction SilentlyContinue
Stop-Process -Name talon_console -Force -ErrorAction SilentlyContinue
Start-Sleep 1
}

Remove-Item "$env:APPDATA\talon" -Recurse -Force -ErrorAction SilentlyContinue

Get-Service | Where-Object { $_.Name -like "*tobi*" } | ForEach-Object {
    Stop-Service $_.Name -Force
    Set-Service $_.Name -StartupType Disabled
}

Set-Location $env:TEMP
KillTalon

downloadFile "https://talonvoice.com/update/**REDACTED*********REDACTED*********REDACTEDs1PrSeh/talon-windows-115-0.4.0-1397-5ef0.exe" "$env:TEMP\talon-installer.exe"

Start-Process "$env:TEMP\talon-installer.exe" -Verb RunAs -ArgumentList "/S" -Wait

Start-Process git -ArgumentList "clone https://github.com/talonhub/community `"$env:APPDATA\talon\user`"" -ErrorAction SilentlyContinue | Out-Null

@("plugin\mouse","core\app_switcher","apps\wsl") |
    ForEach-Object { Remove-Item "$env:APPDATA\talon\user\$_" -Recurse -Force -ErrorAction SilentlyContinue }



Start-Sleep 20
$bad = Get-ChildItem "$env:APPDATA\talon\user" -Recurse -Filter "*.py" |
    Select-String -Pattern "import win32|import pythoncom|from win32" |
    Select-Object -ExpandProperty Path -Unique
if ($bad) {
    Write-Host "WARNING: pywin32 imports found in:"
    $bad | ForEach-Object { Write-Host "  $_"; Remove-Item (Split-Path $_) -Recurse -Force -ErrorAction SilentlyContinue }
    Write-Host "Removed. Restarting Talon to apply...."
    KillTalon
    Start-Process "C:\Program Files\Talon\talon_console.exe"

} else {
    Write-Host "Validation passed: no pywin32 imports found."
}

Write-Host "Monitoring Talon GPU usage (Ctrl+C to stop)..."
while ($true) {
    $talonPid = (Get-Process -Name talon -ErrorAction SilentlyContinue | Select-Object -First 1).Id
    if (-not $talonPid) { Write-Host "Waiting for talon.exe..."; Start-Sleep 3; continue }
    $vram = Get-Counter "\GPU Process Memory(pid_${talonPid}*)\Dedicated Usage" -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty CounterSamples | Measure-Object -Property CookedValue -Sum
    $gpu = Get-Counter "\GPU Engine(pid_${talonPid}*)\Utilization Percentage" -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty CounterSamples | Measure-Object -Property CookedValue -Sum
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] VRAM: $([math]::Round($vram.Sum/1MB))MB | GPU Engine: $([math]::Round($gpu.Sum,1))%"
    Start-Sleep 2
}
