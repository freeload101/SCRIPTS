echo `date` INFO: Performing smart 192,172 and 10. scans this takes about 5-7 days

echo `date` INFO: Starting 192.
nmap -v -T5 -oA 192 -sV --top-ports 40 --open --randomize-hosts --defeat-rst-ratelimit  192.168.0.0/16

# scan 10 and 172 just  1,2,3,10,20,30,100,254 
echo `date` INFO: Starting 172.
nmap --max-retries 1 --min-parallelism 100 -oA 172_GUESS --top-ports 20 -T5 --open --randomize-hosts --defeat-rst-ratelimit  172.16-31.0-255.1,2,3,10,20,30,100,254
grep open 172_GUESS.gnmap | awk '{print $2}'  | sed -r  's/(.*\..*\..*\.).*/\10\/24/'g | sort -u > 172_NETWORKS
nmap -v -T5 -oA 172_NETWORKS -sV  --top-ports 40 --open --randomize-hosts --defeat-rst-ratelimit -iL 172_NETWORKS

echo `date` INFO: Starting 10.
nmap --max-retries 1 --min-parallelism 100 -oA 10_GUESS --top-ports 20 -T5 --open --randomize-hosts --defeat-rst-ratelimit 10.0-255.0-255.1,254
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

# create Nmap fingerprint hash of NMAP service output to find like host on the network
echo "IP,HostName,Hash,Ports" > ./IP_DNS_HASH_PORT.csv
cat *.gnmap | sort -u | grep -v Up | sed 's/,/ /g' |sed -r 's/Host: (.*) \((.*)\).*Ports: (.*)/echo "\1","\2",`echo "\3"|base64 -w 0`",\3"/ge' >> ./IP_DNS_HASH_PORT.csv
