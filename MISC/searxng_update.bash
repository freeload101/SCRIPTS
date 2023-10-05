# wipe EVERYTHING  
docker rm -f $(docker ps -a -q)
sleep  5
docker rmi -f $(docker images -q)
mkdir /opt
cd /opt
rm -Rf /opt/searxng

#pull docker
docker pull searxng/searxng
docker run  -d -p 8080:8080 -v "/opt/searxng:/etc/searxng" -e "BASE_URL=http://localhost:8080/"  -e "INSTANCE_NAME=Not Google" searxng/searxng
 
# setup the image config and branding 
wget "https://raw.githubusercontent.com/freeload101/SCRIPTS/master/MISC/searxng_docker_script.sh"
docker cp searxng_docker_script.bash `docker ps -a -q|head -n 1`:/tmp/searxng_docker_script.sh
docker exec -it `docker ps -a -q|head -n 1` /bin/sh -c "chmod 777 /tmp/searxng_docker_script.sh"
docker exec -it `docker ps -a -q|head -n 1` /bin/sh -c "/tmp/searxng_docker_script.sh"


# make whatever changes you like .. to the conf
# I can't auto remove goole for the life of me ... so i have to disable google / qwant and duckduckgo by hand none of them work 1/2 the time

docker exec -it `docker ps -a -q|head -n 1` /bin/sh -c "vi /etc/searxng/settings.yml"
 
# set to auto restart
docker update --restart=always `docker ps -a -q|head -n 1`
docker container restart  `docker ps -a -q|head -n 1`


# tail logs
docker logs -f `docker ps -a -q|head -n 1`
