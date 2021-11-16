#!/bin/bash

apt install dos2unix -y

IFS=$'\n'

# TODO:
# ADD VT SCORE FOR DOMAIN


rm -f tmp* tmp_cookie *DOMAIN* 2> /dev/null





for i in `cat $1`
do
echo "${i}"
echo URL:"${i}" >> tmp_out

# is the entry a URL or DOMAIN ?
export VAR_DOMAIN=`echo "${i}" | sed -e 's/htt[p|ps]:\/\///g' -e 's/\/.*//g'`
export VAR_STRIP=`echo "${i}" | sed -e 's/htt[p|ps]:\/\///g' -e 's/\/$//g'`


if [[ "${VAR_DOMAIN}" == "${VAR_STRIP}"  ]]
then
export VARURLFILE="${VAR_DOMAIN}"
export VAR_CURL_GREPFILE=tmp_curl_DOMAIN_"${VARURLFILE}"
export VARFILEARRAY+=(tmp_curl_DOMAIN_"${VARURLFILE}")

echo BASECONTENT:SAME >> tmp_out


else
export VARURLFILE=`echo "${i}"|sed 's/\//_/g' | sed 's/:/_/g'`


# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Entry is not the same as domain lets make sure they are really different
curl   -A 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.111 Safari/537.36'  -m2 -skL "${i}"  >tmp_curl_URL_"${VARURLFILE}" 2>&1
curl  -b tmp_cookie -c tmp_cookie   -A 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.111 Safari/537.36'   -m2 -skL "${VAR_DOMAIN}"  >tmp_curl_DOMAIN_"${VARURLFILE}" 2>&1



NUMLINSDIFF=`sdiff -a -B -b -s tmp_curl_URL_"${VARURLFILE}"  tmp_curl_DOMAIN_"${VARURLFILE}" | wc -l`

if [[ "NUMLINSDIFF" -lt "5" ]]
then
rm tmp_curl_URL_"${VARURLFILE}"
export VAR_CURL_GREPFILE=tmp_curl_DOMAIN_"${VARURLFILE}"
export VARFILEARRAY+=(tmp_curl_DOMAIN_"${VARURLFILE}")

echo BASECONTENT:SAME >> tmp_out

else
echo BASECONTENT:DIFFERENT >> tmp_out

export VAR_CURL_GREPFILE=tmp_curl_URL_"${VARURLFILE}"
rm tmp_curl_DOMAIN_"${VARURLFILE}"
export VARFILEARRAY+=(tmp_curl_URL_"${VARURLFILE}")
fi




fi






export VARDIG=`dig  "${VAR_DOMAIN}" ANY`


export varIP=`nmap -PN -sP ${i} | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | head -n 1`
echo IP:`nmap -PN -sP ${i} | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | sort -u` >> tmp_out
echo MX:`echo "${VARDIG}"  | grep "\bMX\b" | head -n 1 | awk '{print $6}' |sed 's/\.$//g'` >> tmp_out

# whois domain

export VARWHOIS=`whois "${VAR_DOMAIN}"`

export VARREGEX=".*\bcsc.*"

if [[ "${VARWHOIS,,}" =~ $VARREGEX ]]
then
echo WHOIS_DOMAIN:CSC >> tmp_out
else
echo  "${VARWHOIS,,}" |grep -A 1  --no-group-separator -iaE "(CIDR|Organization|OrgName|Address|\bcorporate domains|Registrant|registrar|\bcsc|@csc)" | grep -vE "(date|phone|email)"| tr -d '\n'  | xargs -0 echo WHOIS_DOMAIN:  >> tmp_out
fi

# WHOIS IP
export VARWHOIS=`whois "${varIP}"`

export VARREGEX=".*\bcsc.*"

if [[ "${VARWHOIS,,}" =~ $VARREGEX ]]
then
echo WHOIS_IP:CSC >> tmp_out
else
echo  "${VARWHOIS,,}" |grep -A 1  --no-group-separator -iaE "(CIDR|Organization|OrgName|Address|\bcorporate domains|Registrant|registrar|\bcsc|@csc)" | grep -vE "(date|phone|email)"| tr -d '\n'  | xargs -0 echo WHOIS_IP:  >> tmp_out
fi




# nmap check
# nmap -T5 --open --top-ports 20 -sV -oA "${i}" "${i}" > /dev/null


curl  -b tmp_cookie -c tmp_cookie   -A 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.111 Safari/537.36'  -v -i -s -m2 -ikL "${i}"  >"${VAR_CURL_GREPFILE}" 2>&1

# START ALL HEADERS
echo `grep -ia cloudflare "${VAR_CURL_GREPFILE}" | tail -n 1 | xargs -0 echo CLOUDFLARE:` >> tmp_out
echo `grep Location: "${VAR_CURL_GREPFILE}" | tail -n 1 | sed 's/Location: //g'| xargs -0 echo REDIRECT:` >> tmp_out
echo `grep "subject:" "${VAR_CURL_GREPFILE}" |xargs -0 echo CERT:` >> tmp_out
echo `grep -ia -A 1 "<title>" "${VAR_CURL_GREPFILE}"  |tr -d '\n' | sed -r 's/.*<title>(.*)<\/title>.*/\1/gI' | xargs -0 echo TITLE:` >> tmp_out
echo `grep "meta property=" "${VAR_CURL_GREPFILE}"  | sed -r 's/.*property=(.*)/\1/g'|sed 's/\"//g'|sed 's/^ //g'|xargs -0 echo  META:` >> tmp_out
echo `grep -ia login "${VAR_CURL_GREPFILE}" |grep -via "(facebook)"|wc -l|xargs -0 echo LOGIN:` >> tmp_out
echo `grep -iaE "(\bcart\b|add to cart|check out|login|my account|\bprofile\b)" "${VAR_CURL_GREPFILE}" |grep -viaE "(facebook)"|wc -l|xargs -0 echo CART:` >> tmp_out
# NMAP .... echo `grep '\/open' "${i}.gnmap" | tr -d '\n'  | xargs -0 echo NMAP_T20:` >> tmp_out

curl -m2 -sikL "${i}" | grep -iaE "(\&copy;|©)" | grep -Eoia "[0-9]{4,4}"|sort -u |  xargs -0 echo COPYRIGHT:  >> tmp_out



# END ALL HEADERS

# START ALL HEADERS CHECK
echo `grep -ia cloudflare "${VAR_CURL_GREPFILE}" | tail -n 1 | xargs -0 echo CLOUDFLARE:` >> tmp_SINGLE
echo `grep Location: "${VAR_CURL_GREPFILE}" | tail -n 1 | sed 's/Location: //g'| xargs -0 echo REDIRECT:` > tmp_SINGLE
echo `grep "subject:" "${VAR_CURL_GREPFILE}" |xargs -0 echo CERT:` >> tmp_SINGLE
echo `grep -ia -A 1 "<title>" "${VAR_CURL_GREPFILE}"  |tr -d '\n' | sed -r 's/.*<title>(.*)<\/title>.*/\1/gI' | xargs -0 echo TITLE:` >> tmp_SINGLE
echo `grep "meta property=" "${VAR_CURL_GREPFILE}"  | sed -r 's/.*property=(.*)/\1/g'|sed 's/\"//g'|sed 's/^ //g'|xargs -0 echo  META:`  >> tmp_SINGLE
echo `grep -ia login "${VAR_CURL_GREPFILE}" |grep -via "(facebook)"|wc -l|xargs -0 echo LOGIN:` >> tmp_SINGLE
echo `grep -iaE "(\bcart\b|add to cart|check out|login|my account|\bprofile\b)" "${VAR_CURL_GREPFILE}" |grep -viaE "(facebook)"|wc -l|xargs -0 echo CART:` >> tmp_SINGLE
curl -m2 -sikL "${i}" | grep -iaE "(\&copy;|©)" | grep -Eoia "[0-9]{4,4}"|sort -u |  xargs -0 echo COPYRIGHT: >> tmp_SINGLE


IFS=$'\n'
for i in `cat BRANDS`
        do
        for j in `echo $i|sed -r 's/(^.*)\t(.*)/\1/g'`
                do
                        export VARISIN=`cat tmp_SINGLE |grep -ia "${j}"`
                                if [[ "${VARISIN}" == ""  ]]
                                then
                                        echo VARISIN is Null > /dev/null
                                else
                                        #DEBUGecho VARISIN is "${VARISIN}"
                                        grep -ia "${j}" BRANDS | sed -r 's/(^.*)\t(.*)/\1_\2/g'|sed 's/ /_/g'
                                        echo '####################################'
                                        sleep 10
                                fi
        done
done

# END ALL HEADERS CHECK



tail -n 12 tmp_out
echo 'Sleeping for dig throttling'
sleep 1
done


# dupe checking this can only be done at the end

rm tmp_cookie

for i in "${VARFILEARRAY[@]}"
do


for j in `ls -s tmp_*|grep "${i}" -A 10 -B 10|awk '{print $2}'|grep -v "${i}"`
do

# copare files by lines
NUMLINSDIFF=`sdiff -a -B -b -s "$i" "$j" | wc|awk '{print $2}' 2> /dev/null`

# delete > 3 lines differernt

if [[ "NUMLINSDIFF" -lt "10" ]]
then
echo DUPLICATE:"$i" "$j" are the same >> tmp_out

fi



done



done

echo URL,BASECONTENT,IP,MX,WHOIS_DOMAIN,WHOIS_IP,CLOUDFLARE,REDIRECT,CERT,TITLE,META,LOGIN,CART,COPYRIGHT,DUPLICATE > $1.csv
echo Duplicate count report on the bottom of this table >> $1.csv




dos2unix tmp_out

cat tmp_out| sed -e 's/,/ /g' -e 's/\x0D//g'   | sed 's/\"//g' | sed -e 's/^URL:/,URL:/g'  -e 's/^BASECONTENT:/,/g'  -e 's/^IP:/,/g'  -e 's/^MX:/,/g' -e 's/^WHOIS_DOMAIN:/,/g'  -e 's/^WHOIS_IP:/,/g'  -e 's/^CLOUDFLARE:/,/g'  -e 's/^REDIRECT:/,/g' -e 's/^CERT:/,/g' -e 's/^TITLE:/,/g' -e 's/^META:/,/g' -e 's/^LOGIN:/,/g' -e 's/^CART:/,/g' -e 's/^DUPLICATE:/,/g' -e 's/^COPYRIGHT:/,/g'  | tr -d '\n' | awk '{gsub(",URL:","\n"); print}' >> $1.csv

cp "${1}.csv" /tmp/
