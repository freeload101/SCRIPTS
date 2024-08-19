docker stop $(docker ps -q)
docker volume rm $(docker volume ls -q)
docker rm -f $(docker ps -a -q)
sleep  5
docker rmi -f $(docker images -q)

curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey |sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
&& curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
&& sudo apt-get update

#Install the NVIDIA Container Toolkit packages:
sudo apt-get install -y nvidia-container-toolkit

#Configure the container runtime by using the nvidia-ctk command:
sudo nvidia-ctk runtime configure --runtime=docker
Restart the Docker daemon:
sudo systemctl restart docker


 

docker run -d -p 3000:8080 --network=host  --gpus all --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data -e OLLAMA_BASE_URL=http://0.0.0.0:11434  --name open-webui --restart always ghcr.io/open-webui/open-webui
:cuda 
