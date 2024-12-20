echo '[+] adding libnvidia-container to apt repo'
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey |sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list && sudo apt-get update

export HOME=$PWD

echo '[+] Installing Curl and Net-tools'
apt update
apt install curl net-tools -y

echo '[+] It is recommended to configure the Docker host preferences to give at least 6GB of memory. setting vm.max_map_count=262144'
echo vm.max_map_count=262144 >> /etc/sysctl.conf
sysctl -w vm.max_map_count=262144

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



echo '[+] Installing Ollama'
curl -fsSL https://ollama.com/install.sh | sh

echo '[+] Waiting 45 seconds for Ollama'
sleep 45

echo '[+] Pulling dolphin-llama3 '
# ollama pull gemma2-27b
ollama pull dolphin-llama3
# ollama pull deepseek-coder-v2
# ollama pull HammerAI/openhermes-2.5-mistral
# https://huggingface.co/TheBloke/LLaMA2-13B-Psyfighter2-GGUF/blob/main/llama2-13b-psyfighter2.Q4_K_M.gguf

echo '[+] Installing nvidia-container-toolkit'
sudo apt-get install -y nvidia-container-toolkit

echo '[+] Configure the container runtime by using the nvidia-ctk command:'
sudo nvidia-ctk runtime configure --runtime=docker
 
echo '[+] Restarting Docker'
sudo systemctl restart docker

echo '[+] Installing open-webui:dev-cuda Docker '
docker run -d -p 3000:8080 --network=host  --gpus all --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data -e OLLAMA_BASE_URL=http://0.0.0.0:11434  --name open-webui --restart always ghcr.io/open-webui/open-webui:dev-cuda