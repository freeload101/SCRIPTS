SET DIR=%~dp0%

cd "%DIR%"
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://github.com/vegardit/cygwin-portable-installer/raw/main/cygwin-portable-installer.cmd','%DIR%cygwin-portable-installer.cmd'))"
cmd /c cygwin-portable-installer.cmd
%systemroot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://github.com/transcode-open/apt-cyg/raw/master/apt-cyg','%DIR%\cygwin\bin\apt-cyg'))"



:: run with commands ..
apt-cyg update

apt-cyg upgrade
apt-cyg install git automake cmake  binutils  gcc-core  zlib-devel

:: unpack latest tintin
https://github.com/scandum/tintin/releases/download/2.02.41/tintin-2.02.41.tar.gz
tar -xvf tintin-2.02.41.tar.gz
cd tt/src
./configure


 
checking for pcre.h... no
configure: error: pcre header file not found, is the development part present

pause