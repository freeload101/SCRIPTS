@echo off
echo run this as admin!
 
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CSAgent" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CSBoot" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CSDeviceControl" /v Start /t reg_dword /d 4 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CSFalconService" /v Start /t reg_dword /d 4 /f

echo reboot now or press any key to set it back to normal
pause

Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CSAgent" /v Start /t reg_dword /d 2 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CSBoot" /v Start /t reg_dword /d 0 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CSDeviceControl" /v Start /t reg_dword /d 3 /f
Reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CSFalconService" /v Start /t reg_dword /d 2 /f

echo reboot? or close this window not to reboot
pause
shutdown -r -t 1