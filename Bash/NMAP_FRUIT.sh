export foldername=$(date +%Y%m%d)

mkdir "${foldername}"
mv *.xml "${foldername}"
mv *.gnmap "${foldername}"
mv *.nmap "${foldername}"
mv *.txt  "${foldername}"
mv *.csv "${foldername}"


export varNMAPFlags=' -v -T5  -sV -p 21-23,25,53,80-81,88,623,17990,17988,3283,110-111,113,135,139,143,179,199,363,389,443,445,465,514,548,554,587,636,993,995,1025-1026,1720,1723,2000,3268,3269,3306,3389,5060,5900,6001,8000,8080,8443,8888,9191,10000,32768,50000,7001,135,515,1089,1090,1095,1099,1128,1128,1129,1129,2000,2001,2002,3298,3299,4239,4240,4241,4300,4363,4444,4445,4800,5001,5001,5002,5002,5050,5050,5514,6001,7200,7210,7269,7270,7575,8050,8051,8081,8200,8210,8220,8230,8351,8352,8353,8355,8357,8366,8444,9090,9090,9091,9091,9092,9092,9093,9093,9310,9786,9786,9999,10443,10514,20201,21212,21213,34443,40000,40001,40002,40006,40012,40014,44300,44400,50000,50001,50002,50003,50004,50005,50006,50007,50008,50010,50013,50013,50014,50014,50015,50017,50018,50019,50020,50021,50100,50101,50104,50116,59650,59651,59750,59751,59850,59851,59950,59951,59975,59976,62026,62027,62028,62029,62126,62127,62128,62129,3200-3299,3300-3999,40001-40079,40080-40099,4300-4399,8000-8099,8000-8099,8100-8199,8100-8199,3306,5432,1433,27017,6379,9042,3306,50000  --open --max-rtt-timeout 300ms --max-retries 1  --defeat-rst-ratelimit  -O -sS -sV -sC '

sleep 10

echo `date` INFO: Performing smart 192,172 and 10. scans this takes about 5-7 days

echo `date` INFO: Starting 192.
nmap ${varNMAPFlags} -oA 192 192.168.0.0/16

# scan 10 and 172 just  1,2,3,10,20,30,100,254

echo `date` INFO: Starting 192.
nmap ${varNMAPFlags} -oA 192 192.168.0.0/16

echo `date` INFO: Starting 172.
nmap -T5 --max-rtt-timeout 300ms --max-retries 1  -sP -oA 172_GUESS 172.16-31.0-255.1,2,3,10,20,30,100,254
grep Up 172_GUESS.gnmap | awk '{print $2}'  | sed -r  's/(.*\..*\..*\.).*/\10\/24/'g | sort -u | shuf > 172_NETWORKS
nmap ${varNMAPFlags} -oA 172_NETWORKS -iL 172_NETWORKS

echo `date` INFO: Starting 10.
nmap -T5 --max-rtt-timeout 300ms --max-retries 1  -sP -oA 10_GUESS 10.0-255.0-255.1,254,10,20,30,40,50,60,70,80,90,100,110,120,130,140,150,160,170,180,190,200,210,220
grep Up 10_GUESS.gnmap   | awk '{print $2}' | sed -r  's/(.*\..*\..*\.).*/\10\/24/'g | sort -u | shuf > 10_NETWORKS
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




echo "dumping to Splunk HEC1!!!"
cd /apps/RMCCURDY/NMAP/XtremeNmapParser
rm -Rf ./*.xml ./*.xlsx ./*.csv ./*.json
cp ../172_NETWORKS.xml ./
cp ../10_NETWORKS.xml ./
cp ../192.xml ./

python3 xnp.py -d ./ -M -R --open -C all

sed -re 's/\{\"Hostname\"/\{ \"event\" : \{\"Hostname\"/g' -re 's/$/}/g' merged_nmap_scan_data.json -ibak

curl -k https://http-inputs-XXXXXXXXXXXXXXXXXXXXXXX.splunkcloud.com/services/collector/event -H 'Authorization: Splunk 6adedc7aXXXXXXXXXXXXXXXXccd1fb' -d @merged_nmap_scan_data.json

