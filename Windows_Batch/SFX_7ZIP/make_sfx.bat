del  sfx.7z
del  sfx.exe
CD /D "%~DP0"
rem copy *.* "%temp%"
rem copy 7z920_extra\7zS.sfx "%temp%"
cd FILESGOHERE

..\..\7z a ..\sfx.7z *

cd ..
 
copy /b .\7z920_extra\7zS.sfx + config.txt + sfx.7z sfx.exe
 
pause
sfx.exe