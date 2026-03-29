# Oh My Posh!
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
oh-my-posh font install Meslo
if (!(Test-Path $PROFILE)) { New-Item -Path $PROFILE -Type File -Force }
$c = @'
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\jandedobbeleer.omp.json" | Invoke-Expression
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
function f($n) { Get-ChildItem -Filter "*$n*" -Recurse -ErrorAction SilentlyContinue }
function .. { Set-Location .. }
function c { code $args }
Set-Alias -Name clear -Value Clear-Host
'@
$c | Out-File -FilePath $PROFILE -Encoding utf8
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
oh-my-posh font install Meslo
. $PROFILE
