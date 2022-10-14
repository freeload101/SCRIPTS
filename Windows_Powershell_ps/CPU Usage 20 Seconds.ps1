Set-Variable -Name ErrorActionPreference -Value SilentlyContinue

echo "Computer Name: $env:COMPUTERNAME Dumping Process % for 20 seconds" 
foreach($i in 1..20){
Get-Counter '\Process(*)\% Processor Time' | Select-Object -ExpandProperty countersamples| ? {$_.instanceName -notmatch "^(idle|_total|system)$"} | Where-Object {($_.cookedvalue -gt '1') } | Sort-Object -Property cookedvalue -Descending  | Select-Object instanceName ,cookedvalue|Out-String
Start-Sleep -Seconds 1
}
