function downloadFile($url, $file) {
    $res = [System.Net.HttpWebRequest]::Create($url).GetResponse().GetResponseStream()
    $fs = [System.IO.FileStream]::new($file, 'Create')
    $buf = [byte[]]::new(256KB)
    while (($c = $res.Read($buf, 0, $buf.Length)) -gt 0) { $fs.Write($buf, 0, $c) }
    $fs.Close(); $res.Close()
}

Remove-Item "$env:APPDATA\talon" -Recurse -Force -ErrorAction SilentlyContinue

Get-Service | Where-Object { $_.Name -like "*tobi*" } | ForEach-Object {
    Stop-Service $_.Name -Force
    Set-Service $_.Name -StartupType Disabled
}

Set-Location $env:TEMP
Stop-Process -Name talon -Force -ErrorAction SilentlyContinue
Stop-Process -Name talon_console -Force -ErrorAction SilentlyContinue
Start-Sleep 1

downloadFile "https://talonvoice.com/update/Yfv*****REDACTED*********REDACTED*********REDACTED****eh/talon-windows-115-0.4.0-1397-5ef0.exe" "$env:TEMP\talon-installer.exe"

Start-Process "$env:TEMP\talon-installer.exe" -Verb RunAs -ArgumentList "/S" -Wait

Start-Process git -ArgumentList "clone https://github.com/talonhub/community `"$env:APPDATA\talon\user`"" -ErrorAction SilentlyContinue | Out-Null

@("plugin\mouse","core\app_switcher","core\apps\wsl","apps\finder","apps\safari","apps\apple_terminal","apps\apple_notes","apps\amethyst") |
    ForEach-Object { Remove-Item "$env:APPDATA\talon\user\$_" -Recurse -Force -ErrorAction SilentlyContinue }

Start-Process "C:\Program Files\Talon\talon_console.exe"
