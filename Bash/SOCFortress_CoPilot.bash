#echo "run everything as root FTW !"
#sudo su -
echo " wipe  everything"
cd ~
docker stop $(docker ps -q)
docker volume rm $(docker volume ls -q)
docker rm -f $(docker ps -a -q)
sleep  5
docker rmi -f $(docker images -q)
rm -Rf /opt/CoPilot
echo "install docker"
apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
echo "config docker DNS to default DNS"
export ROUTE=`ip route show default | awk '{print $3}' | head`
echo $ROUTE
echo "{\"dns\":[\"`echo $ROUTE`\"],\"log-driver\":\"json-file\",\"log-opts\":{\"max-size\":\"10m\",\"max-file\":\"3\"},\"mtu\": 1450}" >  /etc/docker/daemon.json
echo "install CoPilot"
mkdir /opt
mkdir /opt/CoPilot
cd /opt/CoPilot

wget https://raw.githubusercontent.com/socfortress/CoPilot/v0.0.8/docker-compose.yml
mkdir data

echo "Create the .env file based on the .env.example"
wget 'https://raw.githubusercontent.com/socfortress/CoPilot/main/.env.example'

echo "get internet IP and update .env with it "
export INTERNETIP=`ip route get 1.1.1.1  | awk '{print $7}' | head -n 1`
sed  -re "s/(ALERT_FORWARDING_IP=)0.0.0.0/\1$INTERNETIP/g"  .env.example > .env

echo "restarting docker"
systemctl daemon-reload
systemctl restart docker

echo "Run Copilot"
docker compose up -d

echo "Waiting for CoPilot to start to show password"
sleep  20
docker logs "$(docker ps --filter ancestor=ghcr.io/socfortress/copilot-backend:latest --format "{{.ID}}")" 2>&1 | grep "Admin user password" | sed -re 's/.*plain=.(.*).$/\1/g' > PASSWORD

cat PASSWORD
