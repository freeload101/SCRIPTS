#!/bin/bash
echo '                  ████░░            ░░████                  '
echo '    ████      ████████░░            ░░████████      ████    '
echo '████████████████████████░░        ░░████████████████████████'
echo '██████████████████████░░░░          ░░██████████████████████'
echo '██████████████████████░░            ░░██████████████████████'
echo '██████████████████████▓▓░░        ░░▓▓██████████████████████'
echo '▒▒██████████████▓▓██████░░        ░░██████████████████████▒▒'
echo '  ██████████▓▓▓▓████████░░        ░░██▓▓▓▓████████████████'
echo '  ████████████████████░░            ░░▓▓▓▓████████████████'
echo '  ░░████▓▓████████████░░            ░░▓▓▓▓██████████████░░'
echo '    ░░▓▓██████████████░░            ░░████████████████░░'
echo '    ░░▓▓██████████████░░            ░░██████████████▓▓░░'
echo '      ░░██████████████░░            ░░██████████████░░'
echo '      ░░██████████████░░            ░░██████████████░░'
echo '        ░░████████████░░            ░░████████████░░    '
echo '        ░░████████████░░            ░░████████████░░    '
echo '        ░░████████████░░            ░░████████████░░    '
echo '          ░░██████████░░            ░░██████████░░      '
echo '          ░░████  ██████░░        ░░████  ██████░░      '
echo '          ░░████████████░░        ░░████▓▓▓▓████░░      '
echo '    ░░      ░░██████████░░        ░░██████████░░      ░░'
echo '    ██░░    ░░██████████░░        ░░▓▓████████░░    ░░██'
echo '    ████░░    ░░██████░░            ░░██████░░    ░░████'
echo '      ██▓▓░░  ░░██████░░            ░░██████░░  ░░▓▓██  '
echo '        ████░░  ░░████░░            ░░████░░  ░░████    '
echo '        ░░██▓▓░░░░████░░            ░░████░░░░████░░    '
echo '            ████░░████░░            ░░████░░████        '
echo '            ░░██░░████░░            ░░████░░██░░        '
echo '                ░░██░░  ░░░░░░░░░░░░  ░░██░░            '
echo '                  ░░  ░░████████████░░  ░░              '
echo '                  ░░░░▓▓██████████████░░░░              '
echo '                  ░░░░████████████████░░                '
echo '                    ░░████████████████░░                '
echo '                      ░░████████████░░                  '
echo '                          ████████                      '
 
echo '==================================================='
# TODO:
# * check cookie if not valid error out
# * catch  'Search auto-finalized' in /preview 


############################# CONFIG
export VAR_USERNAME='CS_USERNAME'
export VAR_PASSWORD='CS_PASSWORD'

# Hostname including port for HTTP Event Collector (HEC) NOT TRAILING SLASHES
export VAR_HOST_PORT='https://localhost:8088'

# Authorization key for Splunk HTTP Event Collector (HEC) Example  332dd4e5-XXXX-XXXX-XXXX-XXXXXXXXXXXX
export VAR_HEC_KEY='332dd4e5-XXXX-XXXX-XXXX-XXXXXXXXXXXX'

# the maxium number of jobs to have before clean all jobs is reached CS max is 10 so I set it to 8 as the threashold just in case. I am running searches in the UI or something.
export VAR_MAXJOBS=99

############################## functions #######################################################################
function GET_CSRF(){
echo \* If cookie hash is not changing then your login is invalid CS has 5min session timeout
export var_xsrf=`curl  -X $'POST' -ikLs -b cookie -c cookie --compressed -H $'Host: falcon.crowdstrike.com' -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0' -H $'Accept: application/json' -H $'Accept-Language: en-US,en;q=0.5' -H $'Accept-Encoding: gzip, deflate' -H $'content-type: application/json' "https://falcon.crowdstrike.com/api2/auth/verify" | grep csrf_token | sed -r 's/.*\"csrf_token\": \"(.*)\",/x-csrf-token: \1/g'`
echo `date` DEBUG: var_xsrf ${var_xsrf}
}

function GO_VT_HASHREPORT(){
GET_CSRF
curl -kLs -b cookie -c cookie --compressed -H $'Host: falcon.crowdstrike.com' -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0' -H $'Accept: application/json' -H $'Accept-Language: en-US,en;q=0.5' -H $'Accept-Encoding: gzip, deflate' -H $'content-type: application/json' -H "${var_xsrf}" "https://falcon.crowdstrike.com/api2/csapi/modules/entities/virustotal/v1?max_age=0&ids=${VAR_VTHASH}" > VT_HASHREPORT.json
python3 -m json.tool  VT_HASHREPORT.json > VT_HASHREPORT_results.json
grep -E "(\"result\"|\"positives\")"  VT_HASHREPORT_results.json | grep -vE "(\"result\": null)" | sort -u  | sed 's/  //g' | sed 's/\"result\": //g'
}

function LOGIN_KEEPSESSTION(){

  
echo `date` DEBUG: Getting xsrf token
export var_xsrf=`curl -ikLs -b cookie -c cookie  --compressed -X $'POST' -H $'Host: falcon.crowdstrike.com' -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0' -H $'Accept: application/json' -H $'Accept-Language: en-US,en;q=0.5' -H $'Accept-Encoding: gzip, deflate' -H $'content-type: application/json' -H $'Origin: https://falcon.crowdstrike.com' -H $'Connection: close' $'https://falcon.crowdstrike.com/api2/auth/csrf'| grep csrf_token | sed 's/\"//g' |awk '{print $2}'`

#echo `date` DEBUG: var_xsrf ${var_xsrf}

echo `date` DEBUG: Logging in
export var_xsrf=`curl  -ikLs -b cookie -c cookie  --compressed -X $'POST' -H $'Host: falcon.crowdstrike.com' -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0' -H $'Accept: application/json' -H $'Accept-Language: en-US,en;q=0.5' -H $'Accept-Encoding: gzip, deflate' -H $'content-type: application/json' -H "x-csrf-token: ${var_xsrf}" -H $'Origin: https://falcon.crowdstrike.com' -H $'Connection: close' --data-binary "{\"username\":\"${VAR_USERNAME}\",\"password\":\"${VAR_PASSWORD}\",\"2fa\":\"${VAR_2FA}\",\"use_csam\":true}" $'https://falcon.crowdstrike.com/auth/login' | grep '\"csrf_token\"' |  sed -r  's/ \"csrf_token\": \"(.*)\",/\1/g'`

 


while true
do 
# keep idle url
curl --retry 10  --retry-delay 10  -ikLs -b cookie -c cookie  --compressed   -i -k -X $'POST' -H $'Host: falcon.crowdstrike.com'   -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0'  -H $'Accept: */*'  -H $'Accept-Language: en-US,en;q=0.5'  -H $'Accept-Encoding: gzip, deflate' -H $"x-csrf-token: ${var_xsrf}"  -H $'content-type: application/json' -H $'Origin: https://falcon.crowdstrike.com' -H $'Connection: close' $'https://falcon.crowdstrike.com/auth/pulse' -c ./cookie -b ./cookie  >> ./out.txt 2>&1 >> ./out.txt
# pull some cookies needed
curl --retry 10  --retry-delay 10  -ikLs -b cookie -c cookie  --compressed   -i -k -X $'POST' -H $'Host: falcon.crowdstrike.com'   -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0'  -H $'Accept: */*'  -H $'Accept-Language: en-US,en;q=0.5'  -H $'Accept-Encoding: gzip, deflate' -H $"x-csrf-token: ${var_xsrf}"  -H $'content-type: application/json' -H $'Origin: https://falcon.crowdstrike.com' -H $'Connection: close' $'https://falcon.crowdstrike.com/eam/en-US/app/eam2/audit_app?earliest=-1m&latest=now' -c ./cookie -b ./cookie  >> ./out.txt 2>&1 >> ./out.txt
echo `date` DEBUG: Cookie file hash: `md5sum cookie|awk '{print $1}'` >> ./out.txt
echo `date` DEBUG: Cookie file hash: `md5sum cookie|awk '{print $1}'`
echo `date` DEBUG: Waiting for search query and keeping session alive...
sleep 25

if [[ "${VAR_QUERY}" != "" ]]
then
echo `date` DEBUG: QUERY provided running Splunk search  
GO_SEARCH
fi


done
}

function GO_SEARCH(){


# check if search,|inputlookup or |lookup is in the search query. 
if [[ (${VAR_QUERY} != search* ) && (${VAR_QUERY} != \|inputlookup* )  && (${VAR_QUERY} != \|lookup* ) ]]
then
echo '**********************************************************************************************'
echo '**********************************************************************************************'
echo `date` DEBUG: '*** WARNING SEARCH JOB DID NOT START WITH SEARCH,|INPUTLOOKUP OR |LOOKUP !!! ***'
echo '**********************************************************************************************'
echo '**********************************************************************************************'
read 
sleep 3
fi




# check if max jobs reached if so kill and wait 60 seconds
export VAR_ALLSIDS=`curl -ikLs -b cookie -c cookie --compressed  -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0' "https://falcon.crowdstrike.com/eam/en-US/splunkd/__raw/servicesNS/csuser/eam2/search/jobs" -H $'Content-Type: application/x-www-form-urlencoded' -H $'X-Requested-With: XMLHttpRequest'|grep '\"sid\">'| sed -r 's/.*\"sid\">(.*)<\/s:key>/\1/g' | sed 's/rt_md_//g'|sort|wc -l`

if [[ "${VAR_ALLSIDS}" -gt "${VAR_MAXJOBS}" ]]
then
clear
echo `date` DEBUG: \*\*\* ERROR MAX SEARCH JOBS REACHED KILLING ALL JOBS \!\!\! \*\*\* 
GO_KILL_ALL_JOBS
echo `date` DEBUG: \*\*\* Sleeping 60 seconds for jobs to finalize before search is performed
exit
fi


# send job and get job sid
export var_sid=`curl -ikLs -b cookie -c cookie -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0' --compressed  "https://falcon.crowdstrike.com/eam/en-US/splunkd/__raw/servicesNS/csuser/eam2/search/jobs?output_mode=json" -H $'Content-Type: application/x-www-form-urlencoded' -H $'X-Requested-With: XMLHttpRequest' --data-urlencode  search="${VAR_QUERY}"  |grep '\"sid\":'| sed -r 's/\{\"sid\":\"(.*)\"\}/\1/g' | tail -n 1`
tail -c 100 ./tmp.json
while true
do
# preview job 
curl -kLs -b cookie -c cookie --compressed  -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0' "https://falcon.crowdstrike.com/eam/en-US/splunkd/__raw/servicesNS/csuser/eam2/search/jobs/${var_sid}/results_preview?output_mode=json" -H $'Content-Type: application/x-www-form-urlencoded' -H $'X-Requested-With: XMLHttpRequest'|head -n 1 > ./tmp.json 2>&1 > ./tmp.json


# check runDuration and scanCount dispatchState eventCount
export var_Status1=`curl -kLs -b cookie -c cookie --compressed  -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0' "https://falcon.crowdstrike.com/eam/en-US/splunkd/__raw/servicesNS/nobody/eam2/search/jobs/${var_sid}" -H $'Content-Type: application/x-www-form-urlencoded' -H $'X-Requested-With: XMLHttpRequest'|egrep -Eia "(runDuration|scanCount|dispatchState|eventCount|final)"`

if [[ (${var_Status1} = *FAILED* )  ]]
then
echo "dispatchState is FAILED Bad Query ?"
break
else 
echo "dispatchState: ${var_Status1}"
fi


echo ''
sleep .1
echo `date` DEBUG: Searching ....

if [[ `head -c 18 tmp.json` == *false* ]]
then
echo `date` DEBUG: Search Complete! Saving output to tmp.json

# save output as broken json ...
curl -kLs -b cookie -c cookie --compressed  -X $'GET' -H $'Host: falcon.crowdstrike.com' -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0' -H $'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H $'Accept-Language: en-US,en;q=0.5' -H $'Accept-Encoding: gzip, deflate' "https://falcon.crowdstrike.com/eam/en-US/api/search/jobs/${var_sid}/results?isDownload=true&timeFormat=%25FT%25T.%25Q%25%3Az&maxLines=0&count=0&filename=555555&outputMode=json" > ./tmp.json 2>&1 > ./tmp.json
# fix broken json ...
sed -i -e '1 s/^{/[{/' -e 's/}}/}},/g'  -e '$s/,$//'  -e "\$a]" tmp.json
# sleep for file output ...
sleep 3
python3 -m json.tool tmp.json > results.json
head -c 500 results.json

unset  VAR_QUERY 

        if [[ "${VAR_2FA}" != "" ]]
        then
        echo `date` DEBUG: 2FA provided keeping sesstion alive
        
        export 2FA=""
        LOGIN_KEEPSESSTION
        fi
fi

if [[ "${VAR_QUERY}" == "" ]]
then
echo `date` DEBUG: No 2FA provided exiting
exit
fi

sleep 1
done
}


function GO_KILL_ALL_JOBS(){
echo Killing all jobs
# get all job ids 
export var_allsids=`curl -ikLs -b cookie -c cookie --compressed  -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0' "https://falcon.crowdstrike.com/eam/en-US/splunkd/__raw/servicesNS/csuser/eam2/search/jobs" -H $'Content-Type: application/x-www-form-urlencoded' -H $'X-Requested-With: XMLHttpRequest'|grep '\"sid\">'| sed -r 's/.*\"sid\">(.*)<\/s:key>/\1/g' | sed 's/.*_//g'|sort`

for i in `echo "${var_allsids}"`
do
echo killing $i 
curl -ikLs -b cookie -c cookie --compressed -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0'  "https://falcon.crowdstrike.com/eam/en-US/splunkd/__raw/servicesNS/csuser/eam2/search/jobs/$i/control" -H $'Content-Type: application/x-www-form-urlencoded' -H $'X-Requested-With: XMLHttpRequest'  -d 'output_mode=json&action=finalize'   >> ./out.txt 2>&1 >> ./out.txt & 
done

exit
}


GO_PLUCK_SEARCH(){
echo `date` DEBUG: Running example batch job


# DNS
while [[ VAR_EARLIEST -lt 8 ]]
do

if [ -z "${VAR_LATEST}" ]
        then
        VAR_EARLIEST=1
        VAR_LATEST="now"
        VAR_LATEST_STRING="now"
        VAR_EARLIEST_STRING="-${VAR_EARLIEST}d@d"
fi


##########################################
# DNS

export VAR_QUERY='search index=json AND (ExternalApiType=Event_UserActivityAuditEvent AND OperationName=detection_update) OR ExternalApiType=Event_DetectionSummaryEvent earliest='"${VAR_EARLIEST_STRING}"' latest='"${VAR_LATEST_STRING}"'
| stats count by ComputerName
| dedup ComputerName
| map maxsearches=200 search="search event_simpleName=DnsRequest ComputerName=$ComputerName$  DomainName!=localhost (FirstIP4Record!=192.168.0.0/16 AND FirstIP4Record!=10.0.0.0/8 AND FirstIP4Record!=172.16.0.0/12 AND FirstIP4Record!=127.0.0.0/8) earliest='"${VAR_EARLIEST_STRING}"' latest='"${VAR_LATEST_STRING}"' | fillnull value=""
|  stats count earliest("timestamp") AS "timestamp" by ComputerName DomainName FirstIP4Record| eval timestamp = substr(timestamp, 1, len(timestamp)-3)"
'
GO_SEARCH
cp results.json  results_DNS_${VAR_EARLIEST}_${VAR_LATEST}.json
echo cp results.json  results_DNS_${VAR_EARLIEST}_${VAR_LATEST}.json


# NETWORK
export VAR_QUERY='search index=json AND (ExternalApiType=Event_UserActivityAuditEvent AND OperationName=detection_update) OR ExternalApiType=Event_DetectionSummaryEvent earliest='"${VAR_EARLIEST_STRING}"' latest='"${VAR_LATEST_STRING}"'
| stats count by ComputerName
| dedup ComputerName
| map maxsearches=200 search="search event_simpleName=NetworkConnect*  ComputerName=$ComputerName$ RPort!=53 RPort!=0 LocalAddressIP4!=255.255.255.255 RemoteAddressIP4!=255.255.255.255 LocalAddressIP4!=127.0.0.1 RemoteAddressIP4!=127.0.0.1 earliest='"${VAR_EARLIEST_STRING}"' latest='"${VAR_LATEST_STRING}"' |table timestamp ComputerName \"Agent IP\" MAC LocalAddressIP4 RemoteAddressIP4  RPort ContextProcessId_decimal|dedup LocalAddressIP4 RemoteAddressIP4| eval timestamp = substr(timestamp, 1, len(timestamp)-3)"
'
GO_SEARCH
cp results.json  results_DNS_${VAR_EARLIEST}_${VAR_LATEST}.json
echo cp results.json  results_DNS_${VAR_EARLIEST}_${VAR_LATEST}.json

# PROCESS
export VAR_QUERY='search index=json AND (ExternalApiType=Event_UserActivityAuditEvent AND OperationName=detection_update) OR ExternalApiType=Event_DetectionSummaryEvent earliest='"${VAR_EARLIEST_STRING}"' latest='"${VAR_LATEST_STRING}"'
| stats count by ComputerName
| dedup ComputerName
| map maxsearches=200 search="search event_simpleName="ProcessRollup2" ComputerName=$ComputerName$    earliest='"${VAR_EARLIEST_STRING}"' latest='"${VAR_LATEST_STRING}"' |table \"Agent IP\" CommandLine ComputerName \"LocalAddressIP4\" \"MAC\" SHA256HashData ParentBaseFileName TargetProcessId_decimal WindowStation aid aip event_platform event_simpleName timestamp FileName | eval timestamp = substr(timestamp, 1, len(timestamp)-3)"
'
GO_SEARCH
cp results.json  results_DNS_${VAR_EARLIEST}_${VAR_LATEST}.json
echo cp results.json  results_DNS_${VAR_EARLIEST}_${VAR_LATEST}.json

if [[ "${VAR_LATEST}" == "now"  ]]
        then
                let VAR_EARLIEST=2
                let VAR_LATEST=1
                VAR_LATEST_STRING="-${VAR_LATEST}d@d"
                VAR_EARLIEST_STRING="-${VAR_EARLIEST}d@d"

        else
                let VAR_EARLIEST=VAR_EARLIEST+1
                let VAR_LATEST=VAR_LATEST+1
                VAR_LATEST_STRING="-${VAR_LATEST}d@d"
                VAR_EARLIEST_STRING="-${VAR_EARLIEST}d@d"
fi

done


}

######################################
# END GO_PLUCK_SEARCH

######################################


GO_UPLOAD(){
if [[ "${VAR_JSON_FILE}" == "" ]] 
then
	echo ERROR: You must spisifiy a json file
	echo Example: "${0}" -j upload "results.json"
	exit
fi

python3 -m json.tool "${VAR_JSON_FILE}" > "${VAR_JSON_FILE}"_PRETTY.json

sed -e 's/\"preview\": false,//g' -e 's/\"result\": {/\"event\": {/g' ""${VAR_JSON_FILE}"_PRETTY.json" > "${VAR_JSON_FILE}"_SED.json
curl -Lk "${VAR_HOST_PORT}/services/collector/event" -H "Authorization: Splunk ${VAR_HEC_KEY}"   -d @"${VAR_JSON_FILE}"_SED.json
}

######################## MAIN

############################# INIT

if [[ "$1" == "" ]]
then
	echo `date` DEBUG: No options provided please use valid option
    echo Usage:
    echo Update \#\#\#\#\# CONFIG section of this script
	echo $0 -t 2FA_TOKEN '(Run in screen or in the background to keep session)'
    echo $0 -q \'QUERY\' if you already have active cookie session
    echo $0 -h \'Virus Total Hash\' 
	echo $0 -j kill '(Kills all sids and jobs)'
	echo $0 -j pluck '(Runs a example batch job of 7day DNS,Network and Process for each host with detections)'
	echo $0 -j upload '(Upload .json file to Splunk using HTTP Event Collector (HEC) Example  -j upload results.json'
	exit
fi


IFS=$'\n'

while getopts h:q:t:j: flag
do
    case "${flag}" in
        h) VAR_VT_HASH=${OPTARG};;
        q) VAR_QUERY=${OPTARG};;
        t) VAR_2FA=${OPTARG};;
        j) VAR_JOB=${OPTARG};;
    esac
done

if [[ "${VAR_2FA}" == "" ]]
then
echo `date` DEBUG: 2FA not provided using existing cookie file to perform search

        if [[ "${VAR_JOB}" == "kill" ]]
        then
        GO_KILL_ALL_JOBS
        exit
        fi

        if [[ "${VAR_JOB}" == "pluck" ]]
        then
	GO_PLUCK_SEARCH
        exit
        fi

        if [[ "${VAR_JOB}" == "upload" ]]
        then
	export VAR_JSON_FILE="${3}"
        GO_UPLOAD
        exit
        fi

        if [[ "${VAR_VT_HASH}" != "" ]]
        then
        GO_VT_HASHREPORT
        exit
        fi

        if [[ "${VAR_PLUCK}" != "" ]]
        then
        GO_PLUCK_SEARCH
        exit
        fi

	if [[ "${VAR_QUERY}" != "" ]]
	then
	GO_SEARCH
	fi

        exit

fi



if [[ "${VAR_2FA}" != "" ]]
then
echo `date` DEBUG: 2FA provided keeping sesstion alive
LOGIN_KEEPSESSTION
fi
