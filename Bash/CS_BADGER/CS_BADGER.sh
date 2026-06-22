#!/bin/bash
echo '==================================================='
# TODO:
# * check cookie if not valid error out
# * catch  'Search auto-finalized' in /preview

############################# CONFIG
export VAR_USERNAME='robert.mccurdy@332dd4e5-XXXX-XXXX-XXXX-XXXXXXXXXXXX'
export VAR_PASSWORD='332dd4e5-XXXX-XXXX-XXXX-XXXXXXXXXXXX'

# Hostname including port for HTTP Event Collector (HEC) no trailing slashes
export VAR_HOST_PORT='https://localhost:8088'

# Authorization key for Splunk HTTP Event Collector (HEC) Example  332dd4e5-XXXX-XXXX-XXXX-XXXXXXXXXXXX
export VAR_HEC_KEY='332dd4e5-XXXX-XXXX-XXXX-XXXXXXXXXXXX'

# the maxium number of jobs to have before clean all jobs is reached CS max is 10 so I set it to 8 as the threashold just in case. I am running searches in the UI or something.
export VAR_MAXJOBS=99

############################## functions #######################################################################
function GET_CSRF(){
        export var_xsrf=`curl  -X $'POST' -ikLs -b cookie -c cookie --compressed -H $'Host: falcon.crowdstrike.com' -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0' -H $'Accept: application/json' -H $'Accept-Language: en-US,en;q=0.5' -H $'Accept-Encoding: gzip, deflate' -H $'content-type: application/json' "https://falcon.crowdstrike.com/api2/auth/verify" | grep csrf_token | sed -r 's/.*\"csrf_token\": \"(.*)\",/x-csrf-token: \1/g'`
        if [[ (${var_xsrf} == "" ) ]]
        then
                echo `date` ERROR: var_xsrf is blank session has expired exiting
                ./EMAIL.sh "Session Expired"
                exit
        fi
}

function GO_VT_HASHREPORT(){
        GET_CSRF
        curl -kLs -b cookie -c cookie --compressed -H $'Host: falcon.crowdstrike.com' -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0' -H $'Accept: application/json' -H $'Accept-Language: en-US,en;q=0.5' -H $'Accept-Encoding: gzip, deflate' -H $'content-type: application/json' -H "${var_xsrf}" "https://falcon.crowdstrike.com/api2/csapi/modules/entities/virustotal/v1?max_age=0&ids=${VAR_VTHASH}" > ./VT_HASHREPORT.json
        # remove junk from json file
        sed -i -r -e 's/(.*)\"scans\".*(\"positives\".*)/\1\2/g' VT_HASHREPORT.json
        # pretty output and format for Splunk
        python -m json.tool ./VT_HASHREPORT.json |  sed -r -e 's/(    \"errors\"|^    \]$).*//g' -e 's/    \"resources\": \[/\"event\":/g'  > VT_HASHREPORT_results.json

}

function LOGIN_KEEPSESSTION(){
# Clean up old cookie
rm cookie
echo `date` DEBUG: Getting xsrf token
export var_xsrf=`curl -ikLs -b cookie -c cookie  --compressed -X $'POST' -H $'Host: falcon.crowdstrike.com' -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0' -H $'Accept: application/json' -H $'Accept-Language: en-US,en;q=0.5' -H $'Accept-Encoding: gzip, deflate' -H $'content-type: application/json' -H $'Origin: https://falcon.crowdstrike.com' -H $'Connection: close' $'https://falcon.crowdstrike.com/api2/auth/csrf'| grep csrf_token | sed 's/\"//g' |awk '{print $2}'`

# echo `date` DEBUG: var_xsrf ${var_xsrf}
sleep 1

echo `date` DEBUG: Logging in
export var_xsrf=`curl  -ikLs -b cookie -c cookie  --compressed -X $'POST' -H $'Host: falcon.crowdstrike.com' -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0' -H $'Accept: application/json' -H $'Accept-Language: en-US,en;q=0.5' -H $'Accept-Encoding: gzip, deflate' -H $'content-type: application/json' -H "x-csrf-token: ${var_xsrf}" -H $'Origin: https://falcon.crowdstrike.com' -H $'Connection: close' --data-binary "{\"username\":\"${VAR_USERNAME}\",\"password\":\"${VAR_PASSWORD}\",\"2fa\":\"${VAR_2FA}\",\"use_csam\":true}" $'https://falcon.crowdstrike.com/auth/login' | grep '\"csrf_token\"' |  sed -r  's/ \"csrf_token\": \"(.*)\",/\1/g'`

while true

do
        # keep idle url
        curl --retry 10  --retry-delay 10  -ikLs -b cookie -c cookie  --compressed   -i -k -X $'POST' -H $'Host: falcon.crowdstrike.com'   -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0'  -H $'Accept: */*'  -H $'Accept-Language: en-US,en;q=0.5'  -H $'Accept-Encoding: gzip, deflate' -H $"x-csrf-token: ${var_xsrf}"  -H $'content-type: application/json' -H $'Origin: https://falcon.crowdstrike.com' -H $'Connection: close' $'https://falcon.crowdstrike.com/auth/pulse' -c ./cookie -b ./cookie  >> ./out.txt 2>&1 >> ./out.txt
        # pull some cookies needed
        curl --retry 10  --retry-delay 10  -ikLs -b cookie -c cookie  --compressed   -i -k -X $'POST' -H $'Host: falcon.crowdstrike.com'   -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0'  -H $'Accept: */*'  -H $'Accept-Language: en-US,en;q=0.5'  -H $'Accept-Encoding: gzip, deflate' -H $"x-csrf-token: ${var_xsrf}"  -H $'content-type: application/json' -H $'Origin: https://falcon.crowdstrike.com' -H $'Connection: close' $'https://falcon.crowdstrike.com/eam/en-US/app/eam2/audit_app?earliest=-1m&latest=now' -c ./cookie -b ./cookie  >> ./out.txt 2>&1 >> ./out.txt
#       curl --retry 10  --retry-delay 10  -ikLs -b cookie -c cookie  --compressed   -i -k -X $'POST' -H $'Host: falcon.crowdstrike.com'   -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0'  -H $'Accept: */*'  -H $'Accept-Language: en-US,en;q=0.5'  -H $'Accept-Encoding: gzip, deflate' -H $"x-csrf-token: ${var_xsrf}"  -H $'content-type: application/json' -H $'Origin: https://falcon.crowdstrike.com' -H $'Connection: close' $'https://falcon.crowdstrike.com/eam/en-US/app/eam2/rpa_detections?earliest=-1m&latest=now&form.computer_tok=*&form.user_tok=*&form.severity_tok=*&form.severity_tok=Critical&form.severity_tok=High&form.severity_tok=Medium&form.severity_tok=Informational&form.country_tok=*&form.rpaOchestratorUrl_tok=*&form.rpaTenantName_tok=*&form.rpaProcessName_tok=*&form.rpaPackageName_tok=*&form.rpaMachineName_tok=*&form.rpaWindowsUser_tok=*&form.rpaRobotName_tok=*&form.customer_tok=*' -c ./cookie -b ./cookie  >> ./out.txt 2>&1 >> ./out.txt
        echo `date` DEBUG: Cookie file hash: `grep splunkd_8000 cookie`
        echo `date` DEBUG: Waiting for search query and keeping session alive...
        sleep 59

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
sleep 3
fi

# check if timestamp is in search query.
if [[ (${VAR_QUERY} != *timestamp* ) ]]
then
echo '**********************************************************************************************'
echo '**********************************************************************************************'
echo `date` DEBUG: '*** TIMESTAMP IS MISSING FOR EASY PARSING AND UPLOAD TO SPLUNK BE SURE TIMESTAMP IS FIRST VALUE TO AUTO PARSE TIME !!! ***'
echo `date` DEBUG: '*** EXAMPLE: stats count latest(timestamp) AS timestamp ***'
echo '**********************************************************************************************'
echo '**********************************************************************************************'
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
./EMAIL.sh "MAX SEARCH JOBS"
exit
fi

# check Session
GET_CSRF

# send job and get job sid
export var_sid=`curl -ikLs -b cookie -c cookie -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0' --compressed  "https://falcon.crowdstrike.com/eam/en-US/splunkd/__raw/servicesNS/csuser/eam2/search/jobs?output_mode=json" -H $'Content-Type: application/x-www-form-urlencoded' -H $'X-Requested-With: XMLHttpRequest' --data-urlencode  search="${VAR_QUERY}"  |grep '\"sid\":'| sed -r 's/\{\"sid\":\"(.*)\"\}/\1/g' | tail -n 1`
while true
do
# preview job
echo -n
curl -kLs -b cookie -c cookie --compressed  -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0' "https://falcon.crowdstrike.com/eam/en-US/splunkd/__raw/servicesNS/csuser/eam2/search/jobs/${var_sid}/results_preview?output_mode=json" -H $'Content-Type: application/x-www-form-urlencoded' -H $'X-Requested-With: XMLHttpRequest'|head -c 100

# check runDuration and scanCount dispatchState eventCount
export var_Status1=`curl -kLs -b cookie -c cookie --compressed  -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0' "https://falcon.crowdstrike.com/eam/en-US/splunkd/__raw/servicesNS/nobody/eam2/search/jobs/${var_sid}" -H $'Content-Type: application/x-www-form-urlencoded' -H $'X-Requested-With: XMLHttpRequest'|egrep -Eia "(runDuration|scanCount|dispatchState|eventCount|final)"`

if [[ (${var_Status1} = *FAILED* )  ]]
then
echo `date` 'DEBUG: dispatchState is FAILED Bad Query'
break
else
echo `date` "DEBUG: dispatchState: ${var_Status1}"
fi
sleep 10
echo `date` DEBUG: Searching ...
echo -n
        if [[ (${var_Status1} = *DONE* )  ]]
        then
        echo `date` DEBUG: Search Complete! Saving output to tmp.json

        # save output as broken json ...
        curl -kLs -b cookie -c cookie --compressed  -X $'GET' -H $'Host: falcon.crowdstrike.com' -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0' -H $'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H $'Accept-Language: en-US,en;q=0.5' -H $'Accept-Encoding: gzip, deflate' "https://falcon.crowdstrike.com/eam/en-US/api/search/jobs/${var_sid}/results?isDownload=true&timeFormat=%25FT%25T.%25Q%25%3Az&maxLines=0&count=0&filename=555555&outputMode=json" > ./tmp.json 2>&1 > ./tmp.json
        tail -n 20 tmp.json
        # sleep for file output ...
        unset  VAR_QUERY
        # break loop because we have retults
        break
        fi
echo -n
sleep 1
echo -n
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
| map maxsearches=200 search="search event_simpleName=DnsRequest ComputerName=$ComputerName$  DomainName!=localhost DomainName!=*.COMPANY.com (FirstIP4Record!=192.168.0.0/16 AND FirstIP4Record!=10.0.0.0/8 AND FirstIP4Record!=172.16.0.0/12 AND FirstIP4Record!=127.0.0.0/8) earliest='"${VAR_EARLIEST_STRING}"' latest='"${VAR_LATEST_STRING}"' | fillnull value=""
|  stats count latest("timestamp") AS "timestamp" by ComputerName DomainName FirstIP4Record"
'
GO_SEARCH
echo `date` DEBUG: cp tmp.json  results_DNS_${VAR_EARLIEST}_${VAR_LATEST}.json
cp tmp.json  results_DNS_${VAR_EARLIEST}_${VAR_LATEST}.json


##########################################
# NETWORK
export VAR_QUERY='search index=json AND (ExternalApiType=Event_UserActivityAuditEvent AND OperationName=detection_update) OR ExternalApiType=Event_DetectionSummaryEvent earliest='"${VAR_EARLIEST_STRING}"' latest='"${VAR_LATEST_STRING}"'
| stats count by ComputerName
| dedup ComputerName
| map maxsearches=200 search="search event_simpleName=NetworkConnect* RPort!=53 RPort!=0 LocalAddressIP4!=255.255.255.255 RemoteAddressIP4!=255.255.255.255 LocalAddressIP4!=127.0.0.1 RemoteAddressIP4!=127.0.0.1 ComputerName=$ComputerName$ earliest='"${VAR_EARLIEST_STRING}"' latest='"${VAR_LATEST_STRING}"' | stats count latest(timestamp) AS timestamp latest(MAC) AS MAC latest(ContextProcessId_decimal) AS ContextProcessId_decimal by ComputerName aip LocalAddressIP4 RemoteAddressIP4 RPort"
'
GO_SEARCH
echo `date` DEBUG: cp tmp.json  results_NETWORK_${VAR_EARLIEST}_${VAR_LATEST}.json
cp tmp.json  results_NETWORK_${VAR_EARLIEST}_${VAR_LATEST}.json

##########################################
# PROCESS
export VAR_QUERY='search index=json AND (ExternalApiType=Event_UserActivityAuditEvent AND OperationName=detection_update) OR ExternalApiType=Event_DetectionSummaryEvent earliest='"${VAR_EARLIEST_STRING}"' latest='"${VAR_LATEST_STRING}"'
| stats count by ComputerName
| dedup ComputerName
| map maxsearches=200 search="search event_simpleName="ProcessRollup2" ComputerName=$ComputerName$ CommandLine!="C:\WINDOWS\\CCM\\*" FileName!="GoogleUpdate.exe" FileName!=Conhost.exe FileName!=Teams.exe FileName!="mssense.exe" FileName!="SenseCncProxy.exe" FileName!="pacjsworker.exe" FileName!="MpCmdRun.exe" FileName!="SenseIR.exe"   earliest='"${VAR_EARLIEST_STRING}"' latest='"${VAR_LATEST_STRING}"' | stats count latest(timestamp) AS timestamp latest(TargetProcessId_decimal) AS TargetProcessId_decimal BY CommandLine ComputerName ParentBaseFileName FileName SHA256HashData"
'

GO_SEARCH

echo `date` DEBUG: cp tmp.json  results_PROCESS_${VAR_EARLIEST}_${VAR_LATEST}.json
cp tmp.json  results_PROCESS_${VAR_EARLIEST}_${VAR_LATEST}.json



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
        echo `date` ERROR: You must spisifiy a json file
        echo `date` DEBUG: Example: "${0}" -j upload "results.json"
        exit
fi


if [[ "${VAR_JSON_FILE}" == *VT_HASHREPORT* ]]
then
        curl -sLk "${VAR_HOST_PORT}/services/collector/event" -H "Authorization: Splunk ${VAR_HEC_KEY}"   -d @"${VAR_JSON_FILE}"
else
        echo "${VAR_JSON_FILE}"
        sleep 10
echo `date` DEBUG: Converting and uploading "${VAR_JSON_FILE}"
sed -i -r -e 's/\"(preview|lastrow)\":\w+,//g' -e 's/\{\"result\"/\"event\"/g' -e 's/(.*),\"timestamp\":\"([[:digit:]]+)([[:digit:]][[:digit:]][[:digit:]])\"(.*)/\{\"time\":\"\2\",\1\4/g' -e 's/\}\}$/\}\},/g' -e '$ s/\}\},/\}\}/g' -e '1 i\['  -e '$a\]' "${VAR_JSON_FILE}"
curl -sLk "${VAR_HOST_PORT}/services/collector/event" -H "Authorization: Splunk ${VAR_HEC_KEY}"   -d @"${VAR_JSON_FILE}"
sleep 1
echo -n
fi

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
        echo $0 -j pluck '(Runs a example batch job of 7day DNS,Network and Process for each host with detection )'
        echo $0 -u file.json '(Upload .json file to Splunk using HTTP Event Collector (HEC)'
        exit
fi


IFS=$'\n'

while getopts h:q:t:j:u: flag
do
    case "${flag}" in
                h) VAR_VT_HASH=${OPTARG};;
                q) VAR_QUERY=${OPTARG};;
                t) VAR_2FA=${OPTARG};;
                j) VAR_JOB=${OPTARG};;
                u) VAR_UPLOAD=${OPTARG};;
        esac
done

if [[ "${VAR_2FA}" == "" ]]
then
        echo `date` DEBUG: 2FA not provided using existing cookie file
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

        if [[ "${VAR_UPLOAD}" != "" ]]
        then
                export VAR_JSON_FILE="${2}"
                GO_UPLOAD
        exit
        fi

        if [[ "${VAR_VT_HASH}" != "" ]]
        then
                export VAR_VTHASH="${2}"
                GO_VT_HASHREPORT
        exit
        fi

        if [[ "${VAR_QUERY}" != "" ]]
        then
        export VAR_QUERY="${VAR_QUERY}"
        GO_SEARCH
        fi
        exit
fi

if [[ "${VAR_2FA}" != "" ]]
then
        echo `date` DEBUG: 2FA provided keeping sesstion alive
        LOGIN_KEEPSESSTION
fi
