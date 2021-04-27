docker stop $(docker ps -aq)

rm -Rf ~/.jitsi-meet-cfg


rm -Rf /root/.docker
mkdir /root/.docker/
rm -Rf /root/.jitsi-meet-cfg
sleep 5


docker rm -f $(docker ps -a -q)
sleep  5
docker rmi -f $(docker images -q)


cd /media/moredata
rm -Rf  /media/moredata/docker-jitsi-meet
rm -Rf /var/lib/docker/*


echo `date` DEBUG: Restarting Docker
systemctl restart docker


echo Sleeping before download
sleep 5
git clone https://github.com/jitsi/docker-jitsi-meet && cd docker-jitsi-meet
cp env.example .env
./gen-passwords.sh
mkdir -p ~/.jitsi-meet-cfg/{web/letsencrypt,transcripts,prosody/config,prosody/prosody-plugins-custom,jicofo,jvb,jigasi,jibri}

# fix ICE https://jitsi.github.io/handbook/docs/devops-guide/devops-guide-docker Interactive Connectivity Establishment
sed 's/#DOCKER_HOST_ADDRESS=192.168.1.1/DOCKER_HOST_ADDRESS=96.32.194.227/g' -i.bak .env


docker-compose up -d


# etherpad stuff broken
#sed 's/etherpad.meet.jitsi/jitsi.rmccurdy.com/g' -i.bak .env
#sed 's/#ETHERPAD_URL_BASE/ETHERPAD_URL_BASE/g' -i.bak .env
#docker-compose -f docker-compose.yml -f etherpad.yml up -d


sleep  5


# broken ? docker-compose --log-level DEBUG  up -d --force-recreate --remove-orphans
# broken ? docker update --restart=always `docker ps -q`

echo Sleeping 20 seconds to start tailing loggs
sleep 10

find /var/lib/docker/containers -iname "*.log" -exec tail -f '{}' \;

# docker container ls
# 1126  docker exec -it d4c89a799fd7 bash
