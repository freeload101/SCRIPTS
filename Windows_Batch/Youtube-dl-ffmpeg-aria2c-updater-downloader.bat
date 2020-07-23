@echo off

echo rmccurdy.com ( total hack job but just got sick of youtube-dl needing to be updated all the time )


cd "%~dp0"

copy /y nul  list.txt > %temp%/null

rd /q/s .\aria2 2> %temp%/null

rd /q/s .\ffmpeg 2> %temp%/null




echo Opening list.txt save/close notepad with the list of URLs you want downloaded!

rem CHOICE /T 5 /C y /CS /D y > %temp%/null

notepad list.txt


:DOWNLOAD

echo Downloading URLs from list.txt

rem SUBS:  youtube-dl --embed-thumbnail --download-archive ytdl-archive.txt --all-subs --embed-subs --merge-output-format mkv --ffmpeg-location .\ -o ".\downloads\%%(uploader)s - %%(title)s - %%(id)s.%%(ext)s" -i -a list.txt  --external-downloader aria2c --external-downloader-args "-x 4 -s 16 -k 1M"   

REM LOW QUALITY: youtube-dl -f "bestvideo[height<=360]+worstaudio/worst[height<=360]"  --embed-thumbnail --download-archive ytdl-archive.txt --all-subs --embed-subs --merge-output-format mkv --ffmpeg-location .\ -o ".\downloads\%%(uploader)s - %%(title)s - %%(id)s.%%(ext)s" -i -a list.txt  --external-downloader aria2c --external-downloader-args "-x 4 -s 16 -k 1M"   
REM LINUX ... youtube-dl --download-archive ytdl-archive.txt --merge-output-format mkv --ffmpeg-location /usr/bin/ -o "%(uploader)s - %(title)s - %(id)s.%(ext)s"  -i -a list.txt  --external-downloader aria2c --external-downloader-args "-x 4 -s 16 -k 1M
youtube-dl --download-archive ytdl-archive.txt --merge-output-format mkv --ffmpeg-location .\ -o ".\downloads\%%(uploader)s - %%(title)s - %%(id)s.%%(ext)s" -i -a list.txt  --external-downloader aria2c --external-downloader-args "-x 4 -s 16 -k 1M"   

IF ERRORLEVEL 1 GOTO ERROR



GOTO THEEND



:ERROR


echo Downloading https://eternallybored.org/misc/wget/1.20.3/64/wget.exe (Warning: May NOT be latest binary !)

powershell "(New-Object Net.WebClient).DownloadFile('https://eternallybored.org/misc/wget/1.20.3/64/wget.exe', '.\wget.exe')"


echo Downloading latest youtube-dl.exe

wget -e robots=off  -nd -q -U "rmccurdy.com" -q "http://yt-dl.org/downloads/latest/youtube-dl.exe" -O youtube-dl.exe


echo Downloading latest aria2


wget -q -U "rmccurdy.com" -q -P aria2  -e robots=off  -nd -r  "https://github.com/aria2/aria2/releases/latest" --max-redirect 1 -l 1 -A "latest,release-*,aria*win*64*.zip" -R '*.gz,release*.zip' 

CHOICE /T 1 /C y /CS /D y > %temp%/null

move .\aria2\*win*64*.zip .\aria2\aria2.zip > %temp%/null

powershell "Expand-Archive .\aria2\aria2.zip -DestinationPath .\aria2\ "

FOR /F "tokens=* delims=" %%A in ('dir/s/b .\aria2\aria2c.exe') do (move  "%%A" .\ ) > %temp%/null

rd /q/s .\aria2 


echo Downloading latest ffmpeg

wget -q -P ffmpeg https://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-latest-win64-static.zip -U "rmccurdy.com"

CHOICE /T 1 /C y /CS /D y > %temp%/null

powershell "Expand-Archive .\ffmpeg\ffmpeg-latest-win64-static.zip  -DestinationPath .\ffmpeg\ "

FOR /F "tokens=* delims=" %%A in ('dir/s/b .\ffmpeg\ffmpeg.exe') do (move  "%%A" .\ ) > %temp%/null

rd /q/s .\ffmpeg


GOTO DOWNLOAD


:THEEND


echo All Done! I hope...

CHOICE /T 5 /C y /CS /D y > %temp%/null


explorer   .\downloads\

pause


