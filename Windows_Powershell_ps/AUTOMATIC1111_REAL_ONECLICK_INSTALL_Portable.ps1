<# 
TODO: 
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

############# CompileVol
function CompileVol
{
    Write-Host "[+] Building Volatility" 
    Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\volatility3-develop\" -ArgumentList " setup.py build " -wait -NoNewWindow
    Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\volatility3-develop\" -ArgumentList " setup.py install " -wait -NoNewWindow

    Write-Host "`n[+] Current Working Directory $VARCD\volatility3-develop\volatility3"
    Start-Process -FilePath "$VARCD\python\tools\Scripts\pyinstaller.exe" -WorkingDirectory "$VARCD\volatility3-develop\volatility3" -ArgumentList "  --upx-dir `"$VARCD\upx-3.96-win64`" ..\vol.spec " -wait -NoNewWindow
    
    Write-Host "[+] Downloading Volatility Symbols ~800MB" 
    downloadFile "https://downloads.volatilityfoundation.org/volatility3/symbols/windows.zip" "$VARCD\windows.zip"
    New-Item -Path "$VARCD\volatility3-develop\volatility3\dist\symbols" -ItemType Directory  -ErrorAction SilentlyContinue |Out-Null

    Write-Host "`n[+] Extracting Volatility Symbols"    
    [System.IO.Compression.ZipFile]::ExtractToDirectory( "$VARCD\windows.zip", "$VARCD\volatility3-develop\volatility3\dist\symbols")


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
            
            Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\stable-diffusion-webui-master" -ArgumentList " -m pip install -r requirements.txt" -wait -NoNewWindow 


            <#
            # lol just use requirments.txt
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install basicsr " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install diffusers " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install fairscale==0.4.4 " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install fonts " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install font-roboto " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install gfpgan " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install gradio==3.9 " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install invisible-watermark " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install numpy " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install omegaconf " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install opencv-python " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install requests " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install piexif " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install Pillow " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install pytorch_lightning==1.7.7 " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install realesrgan " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install scikit-image>=0.19 " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install timm==0.4.12 " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install transformers==4.19.2 " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install torch " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install einops " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install jsonmerge " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install clean-fid " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install resize-right " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install torchdiffeq " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install kornia " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install lark " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install inflection " -wait -NoNewWindow
                Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\python\tools" -ArgumentList " -m pip install GitPython " -wait -NoNewWindow

                #>
  
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

Write-Host "`n[+] Downloading stable-diffusion-webui"
downloadFile "https://github.com/AUTOMATIC1111/stable-diffusion-webui/archive/refs/heads/master.zip" "$VARCD\master.zip"
[System.IO.Compression.ZipFile]::ExtractToDirectory("$VARCD\master.zip", "$VARCD\")

<#
Write-Host "`n[+] Downloading upx-3.96-win64.zip"
downloadFile "https://github.com/upx/upx/releases/download/v3.96/upx-3.96-win64.zip" "$VARCD\upx.zip"
[System.IO.Compression.ZipFile]::ExtractToDirectory("$VARCD\upx.zip", "$VARCD\")
#>

CheckPython



CheckGit

Start-Process -FilePath "cmd" -WorkingDirectory "$VARCD" 

#Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\stable-diffusion-webui-master" -ArgumentList "$VARCD\stable-diffusion-webui-master\launch.py" -wait -NoNewWindow 

<#
#  --skip-torch-cuda-test --precision full --no-half
Start-Process -FilePath "$VARCD\python\tools\python.exe" -WorkingDirectory "$VARCD\stable-diffusion-webui-master" -ArgumentList "$VARCD\stable-diffusion-webui-master\launch.py" -wait -NoNewWindow -RedirectStandardOutput RedirectStandardOutput.txt -RedirectStandardError RedirectStandardError.txt
Start-Sleep -Seconds 2
start RedirectStandardOutput.txt 
start RedirectStandardError.txt
#>
