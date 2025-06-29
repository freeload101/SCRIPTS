# I keep forgetting termux setup
termux-change-repo
pkg update && pkg upgrade -y  
pkg install proot-distro -y
termux-setup-storage  

echo "cd ~/storage/downloads" >> ~/.bashrc
source ~/.bashrc

pkg install yt-dlp -y
