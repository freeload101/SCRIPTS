dxdiag /dontskip /whql:off /64bit /t "%temp%\dxdiag.txt"
systeminfo >> "%temp%\dxdiag.txt"

start /wait cmd /c "msinfo32 /report "%temp%\msinfo32.txt""
type  "%temp%\msinfo32.txt" >>   "%temp%\dxdiag.txt"
powercfg /batteryreport /output "%temp%\battery-report.html"

start  "" "%temp%\battery-report.html"
start "" "%temp%\dxdiag.txt"

