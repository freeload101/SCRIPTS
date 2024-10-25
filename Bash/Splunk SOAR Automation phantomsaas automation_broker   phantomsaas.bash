echo "Enter the base URL for SOAR ( Example https://COMPANY.soar.splunkcloud.com: )  "
read PHANTOM_BASE_URL
docker rm -f $(docker ps -a -q)
sleep  5
docker rmi -f $(docker images -q)



cd /opt

echo '[+] Installing Curl and Net-tools'
apt update
apt install curl net-tools jq -y

echo '[+] Installing Docker'
wget -O DockerInstall.sh https://get.docker.com/
sed 's/sleep 20/sleep .5/g' DockerInstall.sh -i.bak
bash DockerInstall.sh

systemctl start docker
systemctl enable docker 


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




export LATEST=`curl -skl "https://registry.hub.docker.com/v2/repositories/phantomsaas/automation_broker/tags/"  | python3 -m json.tool  |grep -E '(\"name\")' | head -n 1 | sed -re 's/.*: \"(.*)\".*/\1/g'`


docker pull phantomsaas/automation_broker:$LATEST

mkdir /opt/splunk_data 

docker run --env PHANTOM_BASE_URL="${PHANTOM_BASE_URL}" -v /opt/splunk_data -d phantomsaas/automation_broker:$LATEST
sleep 20
docker logs `docker ps | grep broker | awk '{print $1}'`  2> /dev/null | grep -A 2 -E "Key:|Code:"

