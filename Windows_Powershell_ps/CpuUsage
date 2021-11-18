Set-Variable -Name ErrorActionPreference -Value SilentlyContinue

while($true)
{

 Get-Counter '\Process(*)\% Processor Time' | Select-Object -ExpandProperty countersamples| Select-Object -Property instancename, cookedvalue| ? {$_.instanceName -notmatch "^(idle|_total|system)$"} | Sort-Object -Property cookedvalue -Descending| Select-Object -First 10| ft InstanceName,@{L='CPU';E={($_.Cookedvalue/100/$env:NUMBER_OF_PROCESSORS).toString('P')}} -AutoSize
 Start-Sleep -Seconds .5
}
