echo '[+] Installing Curl'
apt update
apt install curl -y



echo '[+] It is recommended to configure the Docker host preferences to give at least 6GB of memory. setting vm.max_map_count=262144'
echo vm.max_map_count=262144 >> /etc/sysctl.conf
sysctl -w vm.max_map_count=262144



echo '[+] Installing Docker'
#curl -sSL https://get.docker.com/ | sh
#systemctl restart  docker

#echo '[+] Installing docker-compose'
#curl -L "https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#chmod +x /usr/local/bin/docker-compose

echo '[+] Download Wazyh https://github.com/wazuh/wazuh-docker.git -b v4.8.2'
git clone https://github.com/wazuh/wazuh-docker.git -b v4.8.2

echo '[+] Setting up Wazuh certs'
echo '[+] NOTE: using docker-compose per docs but docker compose '

cd wazuh-docker/single-node/
docker compose -f generate-indexer-certs.yml run --rm generator


echo '[+] Starting Wazuh '
docker compose up
#docker-compose up -d


echo admin and SecretPassword

max_map_count

 
