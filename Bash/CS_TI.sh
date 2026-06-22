#!/bin/bash

echo Debug: killing curl
# using taskkill and killall
taskkill /F /IM curl.exe 2> /dev/null
killall -9 curl 2> /dev/null


FS=$'\n'
IFS=$'\n'
rm -Rf tmp*






export VAR_CUR_DATE=$(date -d "-${VAR_COUNTER} days " +"%s" )





# get first page
echo getting first page
curl -ikLs  -H "X-CSIX-CUSTID: XXXXXXXXXXXXXXXXXXXXXXXXXXXX" -H "X-CSIX-CUSTKEY: XXXXXXXXXXXXXXXXXXXXXXXXXXXX " -H "Content-Type: application/json"  "https://intelapi.crowdstrike.com/indicator/v2/search/?perPage=1000" -o tmp_file_FIRST &
sleep 10

export VAR_NEXT=`grep "Next-Page" tmp_file_FIRST  | sed 's/.*_marker.lt=//g'| tr -d '\n' | tr -d '\r'`



echo $VAR_NEXT


export VAR_COUNTER=0
while true
do
let  VAR_COUNTER=VAR_COUNTER+1

curl -ikLs  -H "X-CSIX-CUSTID: XXXXXXXXXXXXXXXXXXXXXXXXXXXX" -H "X-CSIX-CUSTKEY: XXXXXXXXXXXXXXXXXXXXXXXXXXXX " -H "Content-Type: application/json"  "https://intelapi.crowdstrike.com/indicator/v2/search/?perPage=1000&_marker.lt=${VAR_NEXT}" -o tmp_file_${VAR_COUNTER} &
sleep 3



while [[ `grep "Next-Page"  tmp_file_${VAR_COUNTER}  | sed 's/.*_marker.lt=//g'| tr -d '\n' | tr -d '\r' 2> /dev/null` == '' ]]
        do
        echo Debug:     Waiting 3 seconds for file to be writen
        sleep 3
done

export VAR_NEXT=`grep "Next-Page"  tmp_file_${VAR_COUNTER}  | sed 's/.*_marker.lt=//g'| tr -d '\n' | tr -d '\r'`


echo Counter  $VAR_COUNTER Next $VAR_NEXT



while [[ `ps -a | grep curl |wc -l` -ge '10' ]]
        do
        echo Debug:     Waiting for downloads to complete `ps -a | grep curl |wc -l`  current
        sleep .5
done



done
