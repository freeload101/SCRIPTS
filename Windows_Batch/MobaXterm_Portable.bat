REM Set some local environment variables to make it more portable
set HOMEDRIVE=%~D0
set APPDATA=%~DP0Users\Moba_Data\AppData\Roaming
set HOMEPATH=%~DP0Users\Moba_Data
set LOCALAPPDATA=%~DP0Users\Moba_Data\AppData\Local
set TEMP=%~DP0Users\Moba_Data\AppData\Local\Temp
set TMP=%~DP0Users\Moba_Data\AppData\Local\Temp
set USERPROFILE=%~DP0Users\Moba_Data


rd /q/s "%~DP0Users\Moba_Data\AppData"

mkdir "%USERPROFILE%"  2> "%USERPROFILE%\null"
mkdir "%USERPROFILE%\AppData" 2>  "%USERPROFILE%\null"
mkdir "%USERPROFILE%\AppData\Local" 2> "%USERPROFILE%\null"
mkdir "%USERPROFILE%\AppData\Local\Temp" 2> "%USERPROFILE%\null"
mkdir "%USERPROFILE%\AppData\Roaming" 2> "%USERPROFILE%\null"
 
