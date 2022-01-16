@echo off
setlocal enabledelayedexpansion

:LOOP
CALL :MENU
CALL :LOOP

:INIT


:: KILL TASKS




:: PATHS
echo %date% %time% INFO: Setting Path and Envroiment Variables 

set BASE=%~dp0


:: JAVA
echo %date% %time% INFO: Setting Java Path and Envroiment Variables 
set JAVA_HOME="%BASE%jdk-11.0.11\"
set PATH="%BASE%jdk-11.0.11\bin";%PATH%
)
EXIT /B 0


echo ========================= rmccurdy.com =========================
:MENU
REM Updated 08/24/2021: Removed chrome because Burp has it's own chrome built in!
echo ========================= rmccurdy.com =========================
ECHO 1.Start Sharphound (runas domain user or from non domain host with runas /netonly /user:"DOMAIN\USER" cmd)
ECHO 2.Start Neo4j ( login neo4j pass password )
ECHO 3.Start Bloodhound ( It may take a while to 1-5min to allow you to connect )
ECHO 4.Start Plumbhound 
ECHO.
CHOICE /C 1234 /N /M "Enter your choice:"

IF ERRORLEVEL 4 CALL :PLUMHOUND
IF ERRORLEVEL 3 CALL :BLOODHOUND
IF ERRORLEVEL 2 CALL :NEO
IF ERRORLEVEL 1 CALL :SHARPHOUND
EXIT /B 0



:SHARPHOUND
CALL :INIT
echo %date% %time% INFO: Starting Sharphound --CollectionMethod All
%~dp0SharpH0und_Robert_McCurdy.exe  --CollectionMethod All --PrettyJson
EXIT /B 0

:: NEO
:NEO
CALL :INIT
echo %date% %time% INFO: Starting Neo4j
taskkill /F /IM java.exe 2> %temp%\null
CHOICE /T 5 /C y /CS /D y > %temp%\null
start "" CMD /c @"!BASE!jdk-11.0.11\bin\java.exe" -cp "!BASE!\neo4j-community-4.3.4/lib/*" -Dbasedir="!BASE!\neo4j-community-4.3.4" org.neo4j.server.startup.Neo4jCommand "console" 
EXIT /B 0

:: BLOODHOUND
:BLOODHOUND
CALL :INIT
echo %date% %time% INFO: Starting Bloodhound Please wait 15 Seconds
CHOICE /T 15 /C y /CS /D y > %temp%\null
start /i cmd /c "!BASE!BloodHound-win32-x64\BloodH0und_Robert_McCurdy_TEST.exe"
EXIT /B 0


:: PLUMHOUND
:PLUMHOUND
CALL :INIT
set PATH=%BASE%Python3.7_Portable\scripts\;%BASE%Python3.7_Portable\;%BASE%Python3.7_Portable\lib\;%PATH%
taskkill /F /IM python.exe 2> %temp%\null
CHOICE /T 5 /C y /CS /D y > %temp%\null

echo %date% %time% INFO: Starting Plumbhound   
 

cd "%BASE%Python3.7_Portable\"
 
"%BASE%Python3.7_Portable\python.exe" ..\PlumHound-Latest\PlumHound.py -x ..\PlumHound-Latest\tasks\default.tasks -s "bolt://127.0.0.1:7687" -u "neo4j" -p "password" 


EXIT /B 0


