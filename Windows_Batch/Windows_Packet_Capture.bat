echo [+] Running Packet Capture  "%temp%\capture.etl"
#netsh trace start capture=yes tracefile="%temp%\capture.etl" maxsize=512 filemode=circular overwrite=yes report=no correlation=no IPv4.SourceAddress=(192.168.0.2) IPv4.DestinationAddress=(192.168.0.1) Ethernet.Type=IPv4
netsh trace start capture=yes tracefile="%temp%\capture.etl" maxsize=512 filemode=circular overwrite=yes report=no correlation=no Ethernet.Type=IPv4

CHOICE /T 60 /C y /CS /D y > %temp%/null
  
  
  
echo [+] Stopping/Opening Packet Capture  "%temp%\capture.etl"
#netsh trace stop
powershell "(New-Object Net.WebClient).DownloadFile('https://github.com/microsoft/etl2pcapng/releases/download/v1.3.0/etl2pcapng.zip', '%temp%\etl2pcapng.zip')"
powershell "Expand-Archive '%temp%\etl2pcapng.zip' -DestinationPath '%temp%\' -Force"
"%temp%\etl2pcapng\x86\etl2pcapng.exe" "%temp%\capture.etl" "%temp%\capture.etl.pcap"
notepad  "%temp%\capture.etl.pcap"
