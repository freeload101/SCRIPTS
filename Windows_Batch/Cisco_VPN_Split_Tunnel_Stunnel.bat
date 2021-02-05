
REM shh VPN netblocks non routableish ..
REM25.0.0.0/8
REM14.0.0.0/8 
REM5.0.0.0/8

REM Temporary Switch gateway script:

REM Close all browsers ( DNS cache in browsers ... I know right )
REM Flush DNS cache so we don.t have any DNS issues ... ( or better yet disable DNS caching ... )
ipconfig /flushdns

REM Backup current GW settings ..
for /f "tokens=2,3 delims={,}" %%a in ('"WMIC NICConfig where IPEnabled="True" get DefaultIPGateway /value | find "I" "') do set GW1=%%~a
 
REM  set GW to always tunnel GW ...
route delete 0.0.0.0
route add 0.0.0.0 mask 0.0.0.0 YOUR_GATEWAY_IP_HERE


REM Check your IP changed 
start http://rmccurdy.com/ip.php

REM echo Press any key to reset GW back to Default
pause

ipconfig /flushdns

route delete 0.0.0.0
route add 0.0.0.0 mask 0.0.0.0 %GW1%
