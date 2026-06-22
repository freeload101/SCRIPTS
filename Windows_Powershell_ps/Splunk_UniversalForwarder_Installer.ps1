$downloadUri = (Invoke-RestMethod -Method GET -Uri "https://www.splunk.com/en_us/download/universal-forwarder.html?locale=en_us")    -split '"'    -match '.*download.splunk.com.*64.*msi.*' | select -first 1
Invoke-WebRequest -Uri $downloadUri -Out "splunkforwarder-x64-release.msi"
Start-Process -FilePath "msiexec.exe"   -ArgumentList " /i splunkforwarder-x64-release.msi AGREETOLICENSE=Yes /quiet  " -NoNewWindow -Wait
