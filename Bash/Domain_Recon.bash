#!/bin/bash

# check for dos2unix ... apt install dos2unix -y
# set field separator 
IFS=$'\n'

# Clean up old files
rm -f tmp* tmp_cookie *DOMAIN* tmp_SINGLE2> /dev/null

# Main loop OMG this is so ugly 
for i in `cat $1`
do
	echo `date` INFO: "${i}"
	# LOG the URL or Domain to tmp_SINGLE
	echo URL:"${i}" > tmp_SINGLE

	# is the entry a URL or DOMAIN ?
	export VAR_DOMAIN=`echo "${i}" | sed -e 's/htt[p|ps]:\/\///g' -e 's/\/.*//g'`
	export VAR_STRIP=`echo "${i}" | sed -e 's/htt[p|ps]:\/\///g' -e 's/\/$//g'`

	# set the output file names for the current entry
	
	# input is a domain and not a URL
	if [[ "${VAR_DOMAIN}" == "${VAR_STRIP}"  ]]
		then
		
		export VARURLFILE="${VAR_DOMAIN}"
		export VAR_CURL_GREPFILE=tmp_curl_DOMAIN_"${VARURLFILE}"
		export VARFILEARRAY+=(tmp_curl_DOMAIN_"${VARURLFILE}")
		# LOG the BASECONTENT to tmp_SINGLE
		echo BASECONTENT:SAME >> tmp_SINGLE
	else
	# entry is different 
		export VARURLFILE=`echo "${i}"|sed 's/\//_/g' | sed 's/:/_/g'`
		# Entry is not the same as domain lets make sure they are really different
		curl   -A 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.111 Safari/537.36'  -m2 -skL "${i}"  >tmp_curl_URL_"${VARURLFILE}" 2>&1
		curl  -b tmp_cookie -c tmp_cookie   -A 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.111 Safari/537.36'   -m2 -skL "${VAR_DOMAIN}"  >tmp_curl_DOMAIN_"${VARURLFILE}" 2>&1
		
		# check the number of lines between the doman and URL
		NUMLINSDIFF=`sdiff -a -B -b -s tmp_curl_URL_"${VARURLFILE}"  tmp_curl_DOMAIN_"${VARURLFILE}" | wc -l`
		
		# if the number of lines different is less then 5 then it's the same.
		# reason is redirects for paths like bob.com is the same as bob.com/index.html etc ..
		if [[ "NUMLINSDIFF" -lt "5" ]]
			then
			rm tmp_curl_URL_"${VARURLFILE}"
			export VAR_CURL_GREPFILE=tmp_curl_DOMAIN_"${VARURLFILE}"
			# set output file to check for dupes later ...
			export VARFILEARRAY+=(tmp_curl_DOMAIN_"${VARURLFILE}")
			# LOG the BASECONTENT to tmp_SINGLE
			echo BASECONTENT:SAME >> tmp_SINGLE

		else
			# LOG the BASECONTENT to tmp_SINGLE
			echo BASECONTENT:DIFFERENT >> tmp_SINGLE

			export VAR_CURL_GREPFILE=tmp_curl_URL_"${VARURLFILE}"
			rm tmp_curl_DOMAIN_"${VARURLFILE}"
			export VARFILEARRAY+=(tmp_curl_URL_"${VARURLFILE}")
			fi
		fi

	# get MX record for domain
	export VARDIG=`dig  "${VAR_DOMAIN}" MX`

	# get the IP address for a domain
	export varIP=`nmap -P0 -n --max-rtt-timeout 300ms --max-retries 1 -sP ${i} | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | head -n 1`
	# LOG the BASECONTENT to tmp_SINGLE
	echo IP:"${varIP}" >> tmp_SINGLE
	# LOG the MX to tmp_SINGLE
	echo MX:`echo "${VARDIG}"  | grep "\bMX\b" | awk '{print $6}' | sort -u| tail -n 1` >> tmp_SINGLE
	
	# Perform WHOIS on DOMAIN
	export VARWHOIS=`whois "${VAR_DOMAIN}"`
	# set regex for CSC owned whois results
	export VARREGEX=".*\bcsc.*"
	if [[ "${VARWHOIS,,}" =~ $VARREGEX ]]
		then
		# LOG the WHOIS_DOMAIN to tmp_SINGLE
		echo WHOIS_DOMAIN:CSC >> tmp_SINGLE
		else
		# LOG the WHOIS_DOMAIN to tmp_SINGLE
		# tmp_SINGLE ????
		echo  "${VARWHOIS,,}" |grep -A 1  --no-group-separator -iaE "(CIDR|Organization|OrgName|Address|\bcorporate domains|Registrant|registrar|\bcsc|@csc)" | grep -vE "(date|phone|email)"| tr -d '\n' |sed 's/  //g' | xargs -0 echo WHOIS_DOMAIN:  >> tmp_SINGLE
	fi 

	# Perform WHOIS on IP
	export VARWHOIS=`whois "${varIP}"`
	export VARREGEX=".*\bcsc.*"
	if [[ "${VARWHOIS,,}" =~ $VARREGEX ]]
		then
		echo WHOIS_IP:CSC >> tmp_SINGLE
		else
		# LOG the WHOIS_IP to tmp_SINGLE
		echo  "${VARWHOIS,,}" |grep -A 1  --no-group-separator -iaE "(CIDR|Organization|OrgName|Address|\bcorporate domains|Registrant|registrar|\bcsc|@csc)" | grep -vE "(date|phone|email)"| tr -d '\n' |sed 's/  //g' | xargs -0 echo WHOIS_IP:  >> tmp_SINGLE
	fi
	
	# run curl again because we need JUST header info 
	curl  -b tmp_cookie -c tmp_cookie   -A 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.111 Safari/537.36'  -v -i -s -m2 -ikL "${i}"  >"${VAR_CURL_GREPFILE}" 2>&1

	# START ALL HEADERS CHECK
	# tmp_SINGLE ?!?!?!?!?
	echo `grep -ia cloudflare "${VAR_CURL_GREPFILE}" | tail -n 1 | xargs -0 echo CLOUDFLARE:` >> tmp_SINGLE
	echo `grep Location: "${VAR_CURL_GREPFILE}" | tail -n 1 | sed 's/Location: //g'| xargs -0 echo REDIRECT:` >> tmp_SINGLE
	echo `grep "subject:" "${VAR_CURL_GREPFILE}" |xargs -0 echo CERT:` >> tmp_SINGLE
	echo `grep -ia -A 1 "<title>" "${VAR_CURL_GREPFILE}"  |tr -d '\n' | sed -r 's/.*<title>(.*)<\/title>.*/\1/gI' | xargs -0 echo TITLE:` >> tmp_SINGLE
	echo `grep "meta property=" "${VAR_CURL_GREPFILE}"  | sed -r 's/.*property=(.*)/\1/g'|sed 's/\"//g'|sed 's/^ //g'|xargs -0 echo  META:`  >> tmp_SINGLE
	echo `grep -ia login "${VAR_CURL_GREPFILE}" |grep -via "(facebook)"|wc -l|xargs -0 echo LOGIN:` >> tmp_SINGLE
	echo `grep -iaE "(\bcart\b|add to cart|check out|login|my account|\bprofile\b)" "${VAR_CURL_GREPFILE}" |grep -viaE "(facebook)"|wc -l|xargs -0 echo CART:` >> tmp_SINGLE
	curl -m2 -sikL "${i}" | grep -iaE "(\&copy;|©)" | grep -Eoia "[0-9]{4,4}"|sort -u |  xargs -0 echo COPYRIGHT: >> tmp_SINGLE

	# Check BRANDS file
	
	# reset brand var
	export VARBRANDS=""
	export VARBRANDS_TRIM=""

	IFS=$'\n'
	for k in `cat BRANDS`
	do
		for j in `echo $k|sed -r 's/(^.*)\t(.*)/\1/g'`
		do
			export VARISIN=`cat tmp_SINGLE |grep -iaE "(${j})"`
			if [[ "${VARISIN}" == ""  ]]
				then
				#DEBUG echo `date` INFO: No matching Brands for "${VAR_DOMAIN}" 
				echo VARISIN is Null > /dev/null
			else
				#DEBUG echo `date` INFO: Domain $i matches $k
				export VARBRANDS="${VARBRANDS},`grep -iaE "(${j})" BRANDS | sed -r 's/(^.*)\t(.*)/\1_\2,/g'|sed 's/ /_/g'`"
				export VARBRANDS_TRIM=`echo "${VARBRANDS}"| tr -d '\n'`
			fi
		done
	done

	# END ALL HEADERS CHECK

	echo BRAND: "${VARBRANDS_TRIM}" >>tmp_SINGLE	
	# take entry output to tmp_out    
	dos2unix tmp_SINGLE 2> /dev/null
	cat tmp_SINGLE >> tmp_out
	cat tmp_SINGLE  | sed 's/:/: /g'
   
	echo '------------------------------------------------------------------------------------------------'
	echo `date` INFO: 'Sleeping for dig throttling' Completed `grep URL tmp_out | wc -l` of `wc -l "${1}"`
	sleep 1
done

##########################################
# END MAIN GROSS LOOP
##########################################

echo `date` INFO: Main Complete Checking for Dupes
rm tmp_cookie

for i in "${VARFILEARRAY[@]}"
do
	for j in `ls -s tmp_*|grep "${i}" -A 10 -B 10|awk '{print $2}'|grep -v "${i}"`
	do
		# copare files by lines
		NUMLINSDIFF=`sdiff -a -B -b -s "${i}" "${j}" | wc|awk '{print $2}' 2> /dev/null`
		# delete > 3 lines differernt
		if [[ "NUMLINSDIFF" -lt "10" ]]
		then
			echo DUPLICATE:"$i" "$j" are the same >> tmp_SINGLE
		fi
	done
done

echo URL,BASECONTENT,IP,MX,WHOIS_DOMAIN,WHOIS_IP,CLOUDFLARE,REDIRECT,CERT,TITLE,META,LOGIN,CART,COPYRIGHT,BRAND,DUPLICATE > $1.csv

echo Duplicate count report on the bottom of this table >> $1.csv


cat tmp_out| sed -e 's/,/ /g' -e 's/\x0D//g'   | sed 's/\"//g' | sed -e 's/^URL:/,URL:/g'  -e 's/^BASECONTENT:/,/g'  -e 's/^IP:/,/g'  -e 's/^MX:/,/g' -e 's/^WHOIS_DOMAIN:/,/g'  -e 's/^WHOIS_IP:/,/g'  -e 's/^CLOUDFLARE:/,/g'  -e 's/^REDIRECT:/,/g' -e 's/^CERT:/,/g' -e 's/^TITLE:/,/g' -e 's/^META:/,/g' -e 's/^LOGIN:/,/g' -e 's/^CART:/,/g' -e 's/^DUPLICATE:/,/g' -e 's/^COPYRIGHT:/,/g' -e 's/^BRAND:/,/g'  | tr -d '\n' | awk '{gsub(",URL:","\n"); print}' >> $1.csv

cp "${1}.csv" /tmp/
