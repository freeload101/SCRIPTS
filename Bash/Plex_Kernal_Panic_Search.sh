#!/bin/bash
# exersize in leanring better sed skills trying to replace grep etc
IFS=$'\n';
# tail backward (tac)  and pull the matchs for plex segfaulting and pull the month day hour min...
for i in `tac /var/log/kern.log |sed -rn 's/(.*)  (.*) (.*):(.*):(.*) plex .*segfault.*/\1 \2 \3:\4 /p'`
do

#  kern.log format Oct 6 03 28
# plex log format Oct 06, 2021 02:08:24.484 [0x7efdd488f848] WARN - [FFMPEG] -
# do best we can to search for example search for .*Oct.*6.*03.*28.* because month is 1 in kern and 01 in plex...this is an issue at the top of the hour .. 5:59 and 59 seconds ..so don't crash at the 59min and 59 second ..maybe can fix later .. subtract from min and put as range for sed ...

#  replace Oct 6 03 28 with .*Oct.*6.*03.*28.*
export varpanic=`echo "${i}" | sed -r 's/\s/.*/g'`
echo '######################################################################################################################'
echo "Searching for: ${varpanic}"
echo '######################################################################################################################'
# find .log files from the day and look for the timestamp and show matches 100 before the kernal panic to see what plex was doing before it crashed ...
#find  /home/plex/Library/Logs/Plex\ Media\ Server/ -maxdepth 100 -type f -mtime -1  -iname "*.log" -exec grep -H --group-separator="######################################################################################################################" -B 1 -E "(${varpanic})" '{}' \;
find  /home/plex/Library/Logs/Plex\ Media\ Server/ -maxdepth 100 -type f  -exec grep --color=always -H --group-separator="######################################################################################################################" -B 1 -E "(${varpanic})" '{}' \;
done
