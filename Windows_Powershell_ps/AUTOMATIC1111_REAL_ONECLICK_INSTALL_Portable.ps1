<# 

* needs models thats really it ..


TODO: 
* pull and ask if you want to run cmdr2
*warn about existing python env ...
* check for existing python env
* delete files:
c:\users\administrator\appdata\local\pip
c:\users\administrator\appdata\roaming\python\


#> 

# set current directory
$VARCD = (Get-Location)

Set-Location -Path "$VARCD"
Write-Host "`n[+] Current Working Directory $VARCD"
 
# env 
# Path python
$env:Path = "$env:Path;$VARCD\python\tools\Scripts;$VARCD\python\tools;python\tools\Lib\site-packages;$VARCD\PortableGit\cmd"
 
# python
$env:PYTHONHOME="$VARCD\python\tools"
$env:PYTHONPATH="$VARCD\python\tools\Lib\site-packages"

# PortableGit
#$env:GITDIR="$VARCD\SDUI\PortableGit\cmd"


Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression

################################# FUNCTIONS


############# downloadFile
function downloadFile($url, $targetFile)
{
    Write-Host "`n[+] Downloading $url"
    $uri = New-Object "System.Uri" "$url"
    $request = [System.Net.HttpWebRequest]::Create($uri)
    $request.set_Timeout(15000) #15 second timeout
    $response = $request.GetResponse()
    $totalLength = [System.Math]::Floor($response.get_ContentLength()/1024)
    $responseStream = $response.GetResponseStream()
    $targetStream = New-Object -TypeName System.IO.FileStream -ArgumentList $targetFile, Create
    $buffer = new-object byte[] 10KB
    $count = $responseStream.Read($buffer,0,$buffer.length)
    $downloadedBytes = $count
    while ($count -gt 0)
    {
        #[System.Console]::CursorLeft = 0
        #[System.Console]::Write("`nDownloaded {0}K of {1}K", [System.Math]::Floor($downloadedBytes/1024), $totalLength)
        $targetStream.Write($buffer, 0, $count)
        $count = $responseStream.Read($buffer,0,$buffer.length)
        $downloadedBytes = $downloadedBytes + $count
    }
   Write-Host "`n[+] Finished Download"
    $targetStream.Flush()
    $targetStream.Close()
    $targetStream.Dispose()
    $responseStream.Dispose()
}


############# CHECK CheckGit
Function CheckGit {
   if (-not(Test-Path -Path "$VARCD\PortableGit" )) { 
        try {
            Write-Host "[+] Downloading Git" 

            $downloadUri = ((Invoke-RestMethod -Method GET -Uri "https://api.github.com/repos/git-for-windows/git/releases/latest").assets | Where-Object name -like *PortableGit*64*.exe ).browser_download_url
            downloadFile "$downloadUri" "$VARCD\git7zsfx.exe"
            # https://superuser.com/questions/1104567/how-can-i-find-out-the-command-line-options-for-git-bash-exe
            # file:///C:/Users/Administrator/SDUI/git/mingw64/share/doc/git-doc/git-bash.html#GIT-WRAPPER
            Start-Process -FilePath "$VARCD\git7zsfx.exe" -WorkingDirectory "$VARCD\" -ArgumentList " -o`"$VARCD\PortableGit`" -y " -wait -NoNewWindow

           
            }
                catch {
                    throw $_.Exception.Message
                }
            }
        else {
            Write-Host "[+] $VARCD\Git already exists"
            }
} 



############# CHECK PYTHON
Function CheckPython {
   if (-not(Test-Path -Path "$VARCD\python" )) { 
        try {
            Write-Host "[+] Downloading Python nuget package" 
            downloadFile "https://www.nuget.org/api/v2/package/python/3.10.6" "$VARCD\python.zip"
            New-Item -Path "$VARCD\python" -ItemType Directory  -ErrorAction SilentlyContinue |Out-Null
            Write-Host "[+] Extracting Python nuget package" 
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            Add-Type -AssemblyName System.IO.Compression
            [System.IO.Compression.ZipFile]::ExtractToDirectory("$VARCD\python.zip", "$VARCD\python")
                    
            }
                catch {
                    throw $_.Exception.Message
                }
            }
        else {
            Write-Host "[+] $VARCD\python already exists"
            }
} 

### MAIN ###


CheckGit

Write-Host "`n[+] Cloning stable-diffusion-webui"
Start-Process -FilePath "$VARCD\PortableGit\cmd\git.exe" -WorkingDirectory "$VARCD\" -ArgumentList " clone `"https://github.com/AUTOMATIC1111/stable-diffusion-webui.git`" " -wait -NoNewWindow 
CheckPython

 
Start-Process -FilePath "$VARCD\stable-diffusion-webui\webui-user.bat" -WorkingDirectory "$VARCD\stable-diffusion-webui"  -ArgumentList " --listen 0.0.0.0 --theme dark"  -wait -NoNewWindow 

<#
#  --skip-torch-cuda-test --precision full --no-half --medvram 
Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\stable-diffusion-webui-master" -ArgumentList "$VARCD\stable-diffusion-webui-master\launch.py" -wait -NoNewWindow -RedirectStandardOutput RedirectStandardOutput.txt -RedirectStandardError RedirectStandardError.txt
Start-Sleep -Seconds 2
start RedirectStandardOutput.txt 
start RedirectStandardError.txt
#>

Start-Process -FilePath "cmd" -WorkingDirectory "$VARCD" 
