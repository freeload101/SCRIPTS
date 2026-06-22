$t="C:\backup\OpenWebUI\AppData\Local\Temp"
if (Test-Path $t) {
    irm "https://raw.githubusercontent.com/freeload101/SCRIPTS/refs/heads/master/Windows_Powershell_ps/PSQuickKill.ps1" | iex
    Start-Sleep -Seconds 2
    takeown /F $t /A /R /D Y
    icacls $t /reset /T /C /Q
    icacls $t /grant "Administrators:(OI)(CI)F" /T /C /Q
    Set-Location $t
    attrib -R -S -H * /S /D /L
    Get-ChildItem -Path $t -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
}
