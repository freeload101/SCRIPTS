#!/bin/bash
echo "God awful reolink API script" 
echo "USAGE: ${0} IP yyyy mm dd "

export token=`curl -s -i -k -X 'POST' "https://${1}/cgi-bin/api.cgi?cmd=Login" -d '[{"cmd":"Login","param":{"User":{"userName":"admin","password":"password"}}}]'|grep -iPo '(?<="name" : ")\w+(?=")'`

curl -ik "https://${1}/cgi-bin/api.cgi?cmd=GetDevInfo&token=${token}" 

for i in `curl -i -s -k -X $'POST' -d '[{"cmd":"Search","action":0,"param":{"Search":{"channel":0,"onlyStatus":0,"streamType":"main","StartTime":{"year":'"${2}"',"mon":'"${3}"',"day":'"${4}"',"hour":0,"min":0,"sec":0},"EndTime":{"year":'"${2}"',"mon":'"${3}"',"day":'"${4}"',"hour":23,"min":59,"sec":59}}}}]' "https://192.168.2.22/cgi-bin/api.cgi?cmd=Search&token=${token}"|grep -iPo '(?<="name" : ").*(?=")'`
do
	echo Downloading: $i
	export fname=`echo "${i}"|grep -iPo '(?<=[0-9]\/).*'`
	wget --no-hsts --no-check-certificate "https://${1}/cgi-bin/api.cgi?cmd=Download&source=$i&token=${token}" -O "${fname}"
done

curl -ik "https://${1}/cgi-bin/api.cgi?cmd=Logout&token=${token}"