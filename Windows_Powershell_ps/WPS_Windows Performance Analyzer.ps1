# Download the ADK installer
Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2243390"  -OutFile "C:\windows\adksetup.exe"


# Execute the installer
Start-Process -FilePath "C:\windows\adksetup.exe" -ArgumentList " /quiet /norestart /features OptionId.WindowsPerformanceToolkit" -Wait

# Optionally, remove the installer after installation
Remove-Item -Path "C:\windows\adksetup.exe"


# Set Chrome symbols path
$env:_NT_SYMBOL_PATH += ";SRV*C:\Symbols*https://msdl.microsoft.com/download/symbols;SRV*C:\Symbols*https://chrome-symbols.storage.googleapis.com"

# Set Windows symbols path
$env:_NT_SYMBOL_PATH = "SRV*C:\Symbols*https://msdl.microsoft.com/download/symbols"

# Start CPU capture using Windows Performance Recorder (WPR)
Start-Process -FilePath "wpr.exe" -ArgumentList "-start CPU -filemode -profile -detail" -PassThru -NoNewWindow

# Wait for 10 seconds
Start-Sleep -Seconds 10

# Stop the capture and save the file
Start-Process -FilePath "wpr.exe" -ArgumentList "-stop C:\windows\Output.etl" -NoNewWindow -Wait
Start-Sleep -Seconds 10

Set-ItemProperty -Path "HKCU:\Software\Microsoft\WPA\" -Name "LoadSymbols" -Value 1 -Force

Invoke-Item "C:\windows\Output.etl"
