echo '[+] Listing Docker containers'
docker container list -a
docker ps -a -q
sleep 2

echo '[+] stopping/removing all containers'
for i in `docker ps -a -q`
do
docker stop $i
sleep 2
docker rm $i
done

sleep 2

echo '[+] Starting Open-Webui with debug'
docker run -d   -e GLOBAL_LOG_LEVEL="DEBUG"  -e WEBUI_BANNERS="[{\"id\": \"1\", \"type\": \"success\", \"title\": \"Your messages are stored.\", \"content\": \"Your messages are stored and may be reviewed by human people. LLM's are prone to hallucinations, check sources.\", \"dismissible\": true, \"timestamp\": 10}]"   -p 3000:8080 --network=host  --gpus all --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data -e OLLAMA_BASE_URL=http://0.0.0.0:11434  --name open-webui2 --restart always ghcr.io/open-webui/open-webui:cuda


echo '[+] Tailing logs from all containers'
for i in `docker ps -a -q`
do
docker logs "$i" -f &
done


echo '[+] Because WSL has idle kickout ... '
while true ; do date;sleep 10;done


# NO SUB
# https://www.youtube.com/watch?v=JLWXJqTC1Sk

# SUBS
# https://www.youtube.com/watch?v=QXDTkcEHvPA
