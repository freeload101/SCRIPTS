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

echo '[+] Installing Curl'
apt update
apt install curl -y
 
curl -sSL https://get.docker.com/ | sh
 
systemctl start docker
systemctl enable docker

curl -L "https://github.com/docker/compose/releases/download/1.28.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version

echo '[+] It is recommended to configure the Docker host preferences to give at least 6GB of memory. setting vm.max_map_count=262144'
echo vm.max_map_count=262144 >> /etc/sysctl.conf
sysctl -w vm.max_map_count=262144

git clone https://github.com/wazuh/wazuh-docker.git -b v4.2.6 --depth=1
cd ./wazuh-docker

docker-compose -f generate-opendistro-certs.yml run --rm generator

bash ./production_cluster/kibana_ssl/generate-self-signed-cert.sh

bash ./production_cluster/nginx/ssl/generate-self-signed-cert.sh

docker-compose -f production-cluster.yml up -d
