@echo off

echo '-----------------------------------------------------------------------------------------'
echo 'rmccurdy.com ( total hack job but just got sick of youtube-dl needing to be updated all the time )'
echo 'Proxy support for localhost:8080'
echo '-----------------------------------------------------------------------------------------'

CALL :INIT

CALL :OPENLIST

IF "%UPDATE%" == "YES" (

CALL :DLWGET
CALL :CATCH

CALL :DLARIA
CALL :CATCH

CALL :DLFFMPEG
CALL :CATCH


CALL :DLYTDL
CALL :CATCH

)
 

CALL :RIP
CALL :CATCH

CALL :THEEND



:CATCH
IF %ERRORLEVEL% NEQ 0 (
echo %date% %time% INFO: Something went wrong
pause
)
EXIT /B %ERRORLEVEL%

:INIT
cd "%~dp0"

CHOICE /C YN /N /T 5 /D Y /M "Update ALL binaries Y/N?"
IF ERRORLEVEL 1 SET UPDATE=YES
IF ERRORLEVEL 2 SET UPDATE=NO

copy /y nul  list.txt > %temp%/null
 
rd /q/s .\aria2 2> %temp%/null
rd /q/s .\ffmpeg 2> %temp%/null
 
EXIT /B %ERRORLEVEL%

:OPENLIST
cls
echo %date% %time% INFO: Opening list.txt save/close notepad with the list of URLs you want downloaded!
rem CHOICE /T 1 /C y /CS /D y > %temp%/null
notepad list.txt
EXIT /B %ERRORLEVEL%

 

:DLWGET
echo %date% %time% INFO: Downloading wget via Powershell https://eternallybored.org/misc/wget/1.20.3/64/wget.exe (Warning: May NOT be latest binary !)
powershell "(New-Object Net.WebClient).DownloadFile('https://eternallybored.org/misc/wget/1.20.3/64/wget.exe', '.\wget.exe')" > %temp%/null
EXIT /B %ERRORLEVEL%
 
:DLARIA
echo %date% %time% INFO: Downloading latest aria2
wget -q -U "rmccurdy.com" -q -P aria2  -e robots=off  -nd -r  "https://github.com/aria2/aria2/releases/latest" --max-redirect 1 -l 1 -A "latest,aria*win*64*.zip" -R '*.gz,release*.*' --regex-type pcre --accept-regex "aria2-.*-win-64bit-build1.zip"
move .\aria2\*win*64*.zip .\aria2\aria2.zip > %temp%/null
powershell "Expand-Archive .\aria2\aria2.zip -DestinationPath .\aria2\ "  > %temp%/null
FOR /F "tokens=* delims=" %%A in ('dir/s/b .\aria2\aria2c.exe') do (move  "%%A" .\ ) > %temp%/null
rd /q/s .\aria2
EXIT /B %ERRORLEVEL%

:DLFFMPEG
echo %date% %time% INFO: Downloading latest ffmpeg
wget -q -U "rmccurdy.com" -q -P ffmpeg  -e robots=off  -nd -r  "https://github.com/BtbN/FFmpeg-Builds/releases/latest" --max-redirect 1 -l 1 -R '*shared*,*lgpl*,autobuild-*.*' --regex-type pcre --accept-regex "latest.*"  --regex-type pcre --accept-regex "autobuild.*" --regex-type pcre --accept-regex "ffmpeg-n.*-win64-gpl-[0-9].*.zip"
CHOICE /T 1 /C y /CS /D y > %temp%/null
powershell "Expand-Archive .\ffmpeg\*.zip  -DestinationPath .\ffmpeg\ "
FOR /F "tokens=* delims=" %%A in ('dir/s/b .\ffmpeg\ffmpeg.exe') do (move  "%%A" .\ ) > %temp%/null
rd /q/s .\ffmpeg
EXIT /B %ERRORLEVEL%

:DLYTDL
echo %date% %time% INFO: Downloading latest youtube-dl.exe
wget -e robots=off  -nd -q -U "rmccurdy.com" -q "http://yt-dl.org/downloads/latest/youtube-dl.exe" -O youtube-dl.exe
EXIT /B %ERRORLEVEL%

:RIP
echo %date% %time% INFO: Updateing youtube-dl
youtube-dl -U

echo %date% %time% INFO: Downloading URLs from list.txt
rem SUBS:  youtube-dl --embed-thumbnail --download-archive ytdl-archive.txt --all-subs --embed-subs --merge-output-format mkv --ffmpeg-location .\ -o ".\downloads\%%(uploader)s - %%(title)s - %%(id)s.%%(ext)s" -i -a list.txt  --external-downloader aria2c --external-downloader-args "-x 4 -s 16 -k 1M"   
REM LOW QUALITY: youtube-dl -f "bestvideo[height<=360]+worstaudio/worst[height<=360]"  --embed-thumbnail --download-archive ytdl-archive.txt --all-subs --embed-subs --merge-output-format mkv --ffmpeg-location .\ -o ".\downloads\%%(uploader)s - %%(title)s - %%(id)s.%%(ext)s" -i -a list.txt  --external-downloader aria2c --external-downloader-args "-x 4 -s 16 -k 1M"   
REM LINUX ... youtube-dl --download-archive ytdl-archive.txt --merge-output-format mkv --ffmpeg-location /usr/bin/ -o "%(uploader)s - %(title)s - %(id)s.%(ext)s"  -i -a list.txt  --external-downloader aria2c --external-downloader-args "-x 4 -s 16 -k 1M
REM try with proxy too
REM PROXY youtube-dl  --proxy localhost:8080 --download-archive ytdl-archive.txt --merge-output-format mkv --ffmpeg-location .\ -o ".\downloads\%%(uploader)s - %%(title)s - %%(id)s.%%(ext)s" -i -a list.txt  --external-downloader aria2c --external-downloader-args "-x 4 -s 16 -k 1M"

FOR /F "delims==" %%A IN ('type list.txt') DO (
start "" youtube-dl                          --download-archive ytdl-archive.txt --merge-output-format mkv --ffmpeg-location .\ -o ".\downloads\%%(uploader)s - %%(title)s - %%(id)s.%%(ext)s" -i   --external-downloader aria2c --external-downloader-args "-x 4 -s 16 -k 1M" %%A  
)
 

:THEEND
echo %date% %time% INFO: All Done! I hope...
CHOICE /T 5 /C y /CS /D y > %temp%/null
explorer   .\downloads\
pause

