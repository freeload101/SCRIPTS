#dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
#dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

#wsl --update
#wsl --set-default-version 2

#wsl --install 

# fix if you have issues
# wsl --shutdown
# wsl --unregister Ubuntu
# wsl --uninstall
# wsl --update
# wsl --install




##############################################################   wazuh-docker
echo '[+] Installing Curl and Net-tools'
apt update
apt install curl net-tools -y

echo '[+] Installing Docker'
curl -sSL https://get.docker.com/ | sh

systemctl start docker
systemctl enable docker

echo '[+] Installing docker-compose binary'

curl -L "https://github.com/docker/compose/releases/download/1.28.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version

echo '[+] It is recommended to configure the Docker host preferences to give at least 6GB of memory. setting vm.max_map_count=262144'
echo vm.max_map_count=262144 >> /etc/sysctl.conf
sysctl -w vm.max_map_count=262144




echo '[+] Downloading wazuh-docker 4.2.6 !'
git clone https://github.com/wazuh/wazuh-docker.git -b v4.2.6 --depth=1
cd ./wazuh-docker


echo '[+] Generating Certs wazuh-docker 4.2.6 !'
docker-compose -f generate-opendistro-certs.yml run --rm generator
bash ./production_cluster/kibana_ssl/generate-self-signed-cert.sh
bash ./production_cluster/nginx/ssl/generate-self-signed-cert.sh


echo '[+] Starting Wazuh production-cluster'
docker-compose -f production-cluster.yml up -d


##############################################################  CoPilot
echo '[+] config docker DNS to default DNS'
export ROUTE=`ip route show default | awk '{print $3}' | head`
echo $ROUTE
echo "{\"dns\":[\"`echo $ROUTE`\"],\"log-driver\":\"json-file\",\"log-opts\":{\"max-size\":\"10m\",\"max-file\":\"3\"},\"mtu\": 1450}" >  /etc/docker/daemon.json
echo '[+] install CoPilot'
mkdir /opt
mkdir /opt/CoPilot
cd /opt/CoPilot

wget https://raw.githubusercontent.com/socfortress/CoPilot/v0.0.8/docker-compose.yml
mkdir data

echo '[+] Create the .env file based on the .env.example'
wget 'https://raw.githubusercontent.com/socfortress/CoPilot/main/.env.example'

echo '[+] get internet IP and update .env with it'
export INTERNETIP=`ip route get 1.1.1.1  | awk '{print $7}' | head -n 1`
sed  -re "s/(ALERT_FORWARDING_IP=)0.0.0.0/\1$INTERNETIP/g"  .env.example > .env

echo '[+] Restarting docker'
systemctl daemon-reload
systemctl restart docker

echo '[+] Setting port to 4433 from 433 and 80 to 800 because Wazuh uses 443 and 80'

sed -re 's/443:443/4433:443/g' -re 's/80:80/800:800/g' /opt/CoPilot/docker-compose.yml -i.bak


echo '[+] Run Copilot'
docker compose up -d

echo '[+] Waiting for CoPilot to start to show password'
sleep  20
docker logs "$(docker ps --filter ancestor=ghcr.io/socfortress/copilot-backend:latest --format "{{.ID}}")" 2>&1 | grep "Admin user password" | sed -re 's/.*plain=.(.*).$/\1/g' > PASSWORD
sleep  20
docker logs "$(docker ps --filter ancestor=ghcr.io/socfortress/copilot-backend:latest --format "{{.ID}}")" 2>&1 | grep "Admin user password" | sed -re 's/.*plain=.(.*).$/\1/g' >> PASSWORD
 
 
 
##############################################################  Velociraptor

'[+] Should be setup on https://localhost:8889 with login root and password password from when you setup the conf wizard  ! '
sleep 10

apt update
apt install curl -y

export   VAR_GITHUB_LINUX=`curl -s https://api.github.com/repos/Velocidex/velociraptor/releases/latest | grep -E "(.*download.*linux.*amd64\")" | tail -n 1 | awk '{print $2}'| sed -re 's/.*\"(.*).*\"/\1/g'`
export VAR_GITHUB_WINDOWS=`curl -s https://api.github.com/repos/Velocidex/velociraptor/releases/latest | grep -E "(.*download.*velociraptor-.*-windows-amd64\.msi\")" | tail -n 1 | awk '{print $2}'| sed -re 's/.*\"(.*).*\"/\1/g'`
echo '[+] Downloading latests velociraptor Linux Binary'
wget -q -O velociraptor.bin ${VAR_GITHUB_LINUX}
echo '[+] Downloading latests velociraptor Windows Binary'
wget -q -O velociraptor_ORIG.msi "${VAR_GITHUB_WINDOWS}"

echo '[+] Running velociraptor config generate'
echo '[+] I use port 80 insted of 8000 for reasons ...'
chmod 777 velociraptor.bin
./velociraptor.bin config generate -i 
# FIX FOR INO INTERACTIVE ./velociraptor.bin config generate> /tmp/config.yaml
# FIX ./velociraptor.bin --config /tmp/config.yaml config show --merge '{"Client":{"server_urls":["https://thebeast.rmccurdy.com:8000/"]}}' > /tmp/new_config.yaml


 
sleep 1
 

echo '[+] Creating Deb package'
./velociraptor.bin --config server.config.yaml debian server --binary velociraptor.bin --output velociraptor.deb

echo '[+] Installing Deb package'
dpkg -i velociraptor.deb
sleep 5
systemctl status velociraptor_server | tee out.txt

echo '[+] Repacking MSI with client.config.yaml'
./velociraptor.bin config repack --msi velociraptor_ORIG.msi client.config.yaml velociraptor_REPACKED.msi

echo '[+] Creating api.config.yaml for SOCFortress'
./velociraptor.bin --config server.config.yaml config api_client --name root --role administrator,api api.config.yaml

echo '[+] Updating server.config.yaml to listen on 0.0.0.0'
sed 's/bind_address: 127.0.0.1/bind_address: 0.0.0.0/g' /etc/velociraptor/server.config.yaml -ibak
systemctl restart velociraptor-server
systemctl restart velociraptor_server

echo '[+] get internet IP and update api.config.yaml with it'
export INTERNETIP=`ip route get 1.1.1.1  | awk '{print $7}' | head -n 1`
sed  -re "s/localhost:8001/$INTERNETIP:8001/g"  api.config.yaml -i.bak
cp -R api.config.yaml /mnt/c/delete/


echo '[+] Showing Service/Port info'
grep -B 3 port *.y*


sleep 8





'[+] Should be running on https://localhost:8889 with login root and password password ! '
 

 
 
##############################################################  END 
export INTERNETIP=`ip route get 1.1.1.1  | awk '{print $7}' | head -n 1`
echo '[+] Wazuh Web UI:	https://localhost admin:SecretPassword Wazuh API for SOCFortress CoPilot'
echo '[+] Wazuh API:	https://$INTERNETIP:55000  wazuh-wui:wazuh-wui Wazuh API for SOCFortress CoPilot '
echo '[+] Velociraptor:	https://$INTERNETIP:8889  root:password  SOCFortress CoPilot: port 8001 check api.config.yaml '
echo '[+] Velociraptor API: check api.config.yaml port 8001'
echo "[+] SOCFortress CoPilot: https://$INTERNETIP:4433 admin:`cat PASSWORD` and https://$INTERNETIP:800 "

echo '[+] Showing Service/Port LISTEN info. It can take some time for Wazuh and everything to start!'
netstat -ltpnd
# docker compose down --remove-orphans




