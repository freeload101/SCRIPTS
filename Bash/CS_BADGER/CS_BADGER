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
echo "Destroy All Software" @garybernhardt ....rmccurdy.com
echo \* If cookie hash is not changing then your login is invalid CS has 5min session timeout
echo \*\*\* WARNING ALL SEARCH JOBS MUST START WITH SEARCH\!\!\! \*\*\* 
echo Usage:
echo $0 -t 2FA_TOKEN -q \'QUERY\'
echo $0 -q \'QUERY\' if you already have active cookie session
echo $0 -k kill all jobs

# TODO:
# * check cookie if not valid error out
 



############################# CONFIG
export VAR_USERNAME='XXXXXXXXXXXXXXXXXXXXXXX'
export VAR_PASSWORD='XXXXXXXXXXXXXXXXXXXXXXXXXXXX'
# the maxium number of jobs to have before clean all jobs is reached CS max is 10 so I set it to 8 as the threashold just in case. I am running searches in the UI or something.
export VAR_MAXJOBS=8
 
 



############################## functions #######################################################################
function LOGIN_KEEPSESSTION(){

# just in case our existing cookies break stuff 
rm ./cookie*


 
echo `date` DEBUG: Getting xsrf token
export var_xsrf=`curl -ikLs -b cookie -c cookie  --compressed -X $'POST' -H $'Host: falcon.crowdstrike.com' -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0' -H $'Accept: application/json' -H $'Accept-Language: en-US,en;q=0.5' -H $'Accept-Encoding: gzip, deflate' -H $'content-type: application/json' -H $'Origin: https://falcon.crowdstrike.com' -H $'Connection: close' $'https://falcon.crowdstrike.com/api2/auth/csrf'| grep csrf_token | sed 's/\"//g' |awk '{print $2}'`

#echo `date` DEBUG: var_xsrf ${var_xsrf}

echo `date` DEBUG: Logging in
export var_xsrf=`curl  -ikLs -b cookie -c cookie  --compressed -X $'POST' -H $'Host: falcon.crowdstrike.com' -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0' -H $'Accept: application/json' -H $'Accept-Language: en-US,en;q=0.5' -H $'Accept-Encoding: gzip, deflate' -H $'content-type: application/json' -H "x-csrf-token: ${var_xsrf}" -H $'Origin: https://falcon.crowdstrike.com' -H $'Connection: close' --data-binary "{\"username\":\"${VAR_USERNAME}\",\"password\":\"${VAR_PASSWORD}\",\"2fa\":\"${VAR_2FA}\",\"use_csam\":true}" $'https://falcon.crowdstrike.com/auth/login' | grep '\"csrf_token\"' |  sed -r  's/ \"csrf_token\": \"(.*)\",/\1/g'`

 


while true
do 
# keep idle url
curl   -ikLs -b cookie -c cookie  --compressed   -i -k -X $'POST' -H $'Host: falcon.crowdstrike.com'   -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0'  -H $'Accept: */*'  -H $'Accept-Language: en-US,en;q=0.5'  -H $'Accept-Encoding: gzip, deflate' -H $"x-csrf-token: ${var_xsrf}"  -H $'content-type: application/json' -H $'Origin: https://falcon.crowdstrike.com' -H $'Connection: close' $'https://falcon.crowdstrike.com/auth/pulse' -c ./cookie -b ./cookie  >> ./out.txt 2>&1 >> ./out.txt
# pull some cookies needed
curl   -ikLs -b cookie -c cookie  --compressed   -i -k -X $'POST' -H $'Host: falcon.crowdstrike.com'   -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:72.0) Gecko/20100101 Firefox/72.0'  -H $'Accept: */*'  -H $'Accept-Language: en-US,en;q=0.5'  -H $'Accept-Encoding: gzip, deflate' -H $"x-csrf-token: ${var_xsrf}"  -H $'content-type: application/json' -H $'Origin: https://falcon.crowdstrike.com' -H $'Connection: close' $'https://falcon.crowdstrike.com/eam/en-US/app/eam2/audit_app?earliest=-1m&latest=now' -c ./cookie -b ./cookie  >> ./out.txt 2>&1 >> ./out.txt
echo `date` DEBUG: Cookie file hash: `md5sum cookie|awk '{print $1}'` >> ./out.txt
echo `date` DEBUG: Cookie file hash: `md5sum cookie|awk '{print $1}'`
echo `date` DEBUG: Waiting for search query and keeping session alive...
sleep 290

if [[ "${VAR_QUERY}" != "" ]]
then
echo `date` DEBUG: QUERY provided running Splunk search  
GO_SEARCH
fi


done
}

function GO_SEARCH(){


# check if search is in the search query. 
if [[ "${VAR_QUERY}" != *search* ]]
then
clear
echo `date` DEBUG: \*\*\* ERROR ALL SEARCH JOBS MUST START WITH SEARCH\!\!\! \*\*\* 
exit
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

while true
do
# preview job 
curl -kLs -b cookie -c cookie --compressed  -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0' "https://falcon.crowdstrike.com/eam/en-US/splunkd/__raw/servicesNS/csuser/eam2/search/jobs/${var_sid}/results_preview?output_mode=json" -H $'Content-Type: application/x-www-form-urlencoded' -H $'X-Requested-With: XMLHttpRequest'|head -n 1 > ./tmp.json 2>&1 > ./tmp.json
tail -n 10 ./tmp.json

echo ''
sleep .1
echo `date` DEBUG: Searching ....

if [[ `head -c 18 tmp.json` == *false* ]]
then
# job is completed fetch full results
curl -kLs -b cookie -c cookie --compressed -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0'  "https://falcon.crowdstrike.com/eam/en-US/splunkd/__raw/servicesNS/csuser/eam2/search/jobs/${var_sid}/results?output_mode=json" -H $'Content-Type: application/x-www-form-urlencoded' -H $'X-Requested-With: XMLHttpRequest' > ./tmp.json 2>&1 > ./tmp.json
python3 -m json.tool tmp.json
export VAR_QUERY=""
        if [[ "${VAR_2FA}" != "" ]]
        then
        echo `date` DEBUG: 2FA provided keeping sesstion alive
        
        export 2FA=""
        LOGIN_KEEPSESSTION
        fi
fi

if [[ "${VAR_QUERY}" == "" ]]
then
echo `date` DEBUG: Search Complete! no 2FA provided exiting results writen to tmp.json
exit
fi

sleep 1
done
}


function GO_KILL_ALL_JOBS(){
echo Killing all jobs
# get all job ids 
export var_allsids=`curl -ikLs -b cookie -c cookie --compressed  -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0' "https://falcon.crowdstrike.com/eam/en-US/splunkd/__raw/servicesNS/csuser/eam2/search/jobs" -H $'Content-Type: application/x-www-form-urlencoded' -H $'X-Requested-With: XMLHttpRequest'|grep '\"sid\">'| sed -r 's/.*\"sid\">(.*)<\/s:key>/\1/g' | sed 's/rt_md_//g'|sort`

for i in `echo "${var_allsids}"`
do
echo killing $i 
curl -ikLs -b cookie -c cookie --compressed -H $'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) Gecko/20100101 Firefox/73.0'  "https://falcon.crowdstrike.com/eam/en-US/splunkd/__raw/servicesNS/csuser/eam2/search/jobs/$i/control" -H $'Content-Type: application/x-www-form-urlencoded' -H $'X-Requested-With: XMLHttpRequest'  -d 'output_mode=json&action=finalize'   >> ./out.txt 2>&1 >> ./out.txt & 
done

exit
}



######################## START

############################# INIT
 
IFS=$'\n'
while getopts q:t:k option
do
case "${option}"
in
q) export VAR_QUERY=${OPTARG};;
t) export VAR_2FA=${OPTARG};;
k) 
GO_KILL_ALL_JOBS
;;
esac
done





if [[ "${VAR_2FA}" == "" ]]
then
echo `date` DEBUG: 2FA not provided using existing cookie file to perform search

        if [[ "${VAR_KILL_JOB}" != "" ]]
        then
        echo `date` DEBUG: VAR_KILL_JOB
        GO_KILL_ALL_JOBS
        exit
        fi

        if [[ "${VAR_QUERY}" == "" ]]
        then
        echo `date` DEBUG: No options provided please use -t or -q 
        clear
        exit
        fi


GO_SEARCH
fi

if [[ "${VAR_QUERY}" != "" ]]
then
echo `date` DEBUG: QUERY provided running Splunk search  
GO_SEARCH
fi


if [[ "${VAR_2FA}" != "" ]]
then
echo `date` DEBUG: 2FA provided keeping sesstion alive
LOGIN_KEEPSESSTION
fi
