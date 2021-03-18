dxdiag /dontskip /whql:off /64bit /t c:\dxdiag.txt
systeminfo >> c:\dxdiag.txt

start /wait cmd /c "msinfo32 /report C:\msinfo32.txt"
type  C:\msinfo32.txt >>  c:\dxdiag.txt
powercfg /batteryreport /output "C:\battery-report.html"

start C:\battery-report.html
start C:\dxdiag.txt

