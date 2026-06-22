# I keep forgetting termux setup
termux-change-repo
pkg update && pkg upgrade -y  
pkg install proot-distro -y
termux-setup-storage  

echo "cd ~/storage/downloads" >> ~/.bashrc
source ~/.bashrc

pip install --break-system-packages pipenv
npm install -g n
# curl -fsSL https://get.docker.com | sh


pkg install -y git
pkg install -y curl
pkg install -y wget
pkg install -y yt-dlp
 
