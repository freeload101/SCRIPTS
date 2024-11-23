# TODO:
# * update checks ?


echo '[+] Credit:  dLoProdz and the SOCFortress Open Source SIEM Stack !'
export HOME=$PWD

mkdir /opt/
cd /opt

echo '[+] Installing Curl and Net-tools'
apt update
apt install curl net-tools -y

echo '[+] Installing Docker'
wget -O DockerInstall.sh https://get.docker.com/
sed 's/sleep 20/sleep .5/g' DockerInstall.sh -i.bak
bash DockerInstall.sh

systemctl start docker
systemctl enable docker

echo '[+] config docker DNS to default DNS'
export ROUTE=`ip route show default | awk '{print $3}' | head`
echo $ROUTE
echo "{\"dns\":[\"`echo $ROUTE`\"],\"log-driver\":\"json-file\",\"log-opts\":{\"max-size\":\"10m\",\"max-file\":\"3\"},\"mtu\": 1450}" >  /etc/docker/daemon.json

echo '[+] Restarting docker'
systemctl daemon-reload
systemctl restart docker


echo '[+] Installing docker-compose binary'

curl -L "https://github.com/docker/compose/releases/download/1.28.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version

echo '[+] It is recommended to configure the Docker host preferences to give at least 6GB of memory. setting vm.max_map_count=262144'
echo vm.max_map_count=262144 >> /etc/sysctl.conf
sysctl -w vm.max_map_count=262144
 

echo '[+] clone https://github.com/socfortress/OSSIEM.git'
git clone https://github.com/socfortress/OSSIEM.git
cd /opt/OSSIEM/wazuh/

echo '[+] Configuring Wazuh certs'
docker-compose -f generate-indexer-certs.yml run --rm generator
cp /opt/OSSIEM/wazuh/config/wazuh_indexer_ssl_certs/root-ca.pem /opt/OSSIEM/graylog/
chown 1100:1100 /opt/OSSIEM/graylog/*


echo '[+] #############################################################################################'
echo "[+] # Please enter an IP address or Hostname for the Velociraptor and other remote (outside) clients to connect to:"
echo '[+] #############################################################################################'
read ip_address

echo '[+] Starting docker stack logs located in /opt/OSSIEM/screenlog.0 '
sleep 5
cd /opt/OSSIEM 
screen -fa -d -m -L -S DOCKER bash -c "docker compose up"
 

while [ $(docker ps -q | wc -l) -lt 12 ]; do sleep 1;echo '[+] Starting/Waiting for Docker Stack count of 12'; done
sleep 60
 
echo '[+] Setting up Graylog certs '
docker exec -it graylog /bin/bash -c "cp /opt/java/openjdk/lib/security/cacerts /usr/share/graylog/data/config/;cd /usr/share/graylog/data/config/;cd /usr/share/graylog/data/config/;keytool -noprompt  -importcert -keystore cacerts -storepass changeit -alias wazuh_root_ca -file root-ca.pem"

 


echo '[+] Downloading/Installing SOCFortress Wazuh Rules'
docker exec -it wazuh.manager /bin/bash -c "dnf install git -y;curl -so ~/wazuh_socfortress_rules.sh https://raw.githubusercontent.com/socfortress/OSSIEM/main/wazuh_socfortress_rules.sh;sed '/while true/,/done/d' ~/wazuh_socfortress_rules.sh -i.bak;bash ~/wazuh_socfortress_rules.sh"

 

echo '[+] Building Velociraptor MSI for ${ip_address} '
mkdir /opt/Velociraptor
cd /opt/Velociraptor

export VAR_GITHUB_LINUX=`curl -s https://api.github.com/repos/Velocidex/velociraptor/releases/latest | grep -E "(.*download.*linux.*amd64\")" | tail -n 1 | awk '{print $2}'| sed -re 's/.*\"(.*).*\"/\1/g'`
export VAR_GITHUB_WINDOWS=`curl -s https://api.github.com/repos/Velocidex/velociraptor/releases/latest | grep -E "(.*download.*velociraptor-.*-windows-amd64\.msi\")" | tail -n 1 | awk '{print $2}'| sed -re 's/.*\"(.*).*\"/\1/g'`
echo '[+] Downloading latests velociraptor Linux Binary'
wget -q -O velociraptor.bin ${VAR_GITHUB_LINUX}
echo '[+] Downloading latests velociraptor Windows Binary'
wget -q -O velociraptor_ORIG.msi "${VAR_GITHUB_WINDOWS}"

echo '[+] Running velociraptor config generate'
chmod 777 velociraptor.bin

docker exec -it velociraptor /bin/bash -c "cat client.config.yaml"  > client.config.yaml
sed -re "s/https:\/\/(Velociraptor)/https:\/\/${ip_address}/g" client.config.yaml  -i.bak
./velociraptor.bin config repack --msi velociraptor_ORIG.msi client.config.yaml  "$HOME/velociraptor_REPACKED.msi"
 

echo '[+] velociraptor Downloading/Installing SOCFortress Wazuh Rules'
docker exec -it velociraptor /bin/bash -c "./velociraptor --config server.config.yaml config api_client --name admin --role administrator,api api.config.yaml" > api.config.yaml
docker exec -it velociraptor /bin/bash -c "cat api.config.yaml" > "$HOME/api.config.yaml"
sed -re "s/api_connection_string: 0.0.0.0:8001/api_connection_string: Velociraptor:8001/g" "$HOME/api.config.yaml" -i.bak
 

export INTERNETIP=`ip route get 1.1.1.1  | awk '{print $7}' | head -n 1`
netstat -ltpnd

echo "[+] Greylog: https://$INTERNETIP:9000  admin:yourpassword"
echo "[+] Wazuh Web UI: https://$INTERNETIP:5601 admin:SecretPassword"
echo "[+] Velociraptor: https://$INTERNETIP:8889  root:password"
echo "[+] Grafana: http://$INTERNETIP:3000  admin:admin"

echo "[+] Velociraptor Windows Client and XML config file for CoPilot: $HOME/ "

echo "[+] Wazuh Indexer API: https://$INTERNETIP:9200 admin:SecretPassword"
echo "[+] Wazuh Manager API: https://$INTERNETIP:55000  wazuh-wui:MyS3cr37P450r.*- Wazuh API for SOCFortress CoPilot"

echo "[+]  "

# docker compose down --remove-orphans
echo '[+] Waiting for CoPilot to start to show password'
while true; do
  output=$(docker logs "$(docker ps --filter ancestor=ghcr.io/socfortress/copilot-backend:latest --format "{{.ID}}")" 2>&1 | grep "Admin user password")
  [ -n "$output" ] && echo "[+] SOCFortress https://$INTERNETIP admin : ${output}" && break
  sleep 2
done

echo '[+] #############################################################################################'
echo "[+] # In SOCFortress Verify all Configured connectors and then click the Stack Provisioning button then click deploy. Press enter to restart greylog and wazuh.manager"
echo '[+] #############################################################################################'
read yolo

sleep 5

docker restart wazuh.manager
docker restart graylog
echo '[+] I had to do full docker compose down;sleep 10; docker compose up to get graylog happy...'
