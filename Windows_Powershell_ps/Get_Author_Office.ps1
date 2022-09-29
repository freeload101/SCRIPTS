(Get-ChildItem -Path "\\DEEERPPP\Everyone" -Depth 1 -Filter *.*x) |ForEach-Object { 

$FullName = $_.FullName

$Folder = Split-Path $FullName
$File = Split-Path $FullName -Leaf

$objShell = New-Object -ComObject Shell.Application
$objFolder = $objShell.namespace($Folder)
 

$Item = $objFolder.items().item($File)
$Author = $objFolder.getDetailsOf($Item, 20)

#Write-Host "$FullName,`"$Author`""

$Author = $Author -replace '""',''

Write-Output "$Author;" 

} | sort -Unique |  Out-File -FilePath Author.txt
start Author.txt
