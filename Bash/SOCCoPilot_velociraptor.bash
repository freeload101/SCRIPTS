apt update
apt install curl -y

export   VAR_GITHUB_LINUX=`curl -s https://api.github.com/repos/Velocidex/velociraptor/releases/latest | grep -E "(.*download.*linux.*amd64\")" | tail -n 1 | awk '{print $2}'| sed -re 's/.*\"(.*).*\"/\1/g'`
export VAR_GITHUB_WINDOWS=`curl -s https://api.github.com/repos/Velocidex/velociraptor/releases/latest | grep -E "(.*download.*velociraptor-.*-windows-amd64\.msi\")" | tail -n 1 | awk '{print $2}'| sed -re 's/.*\"(.*).*\"/\1/g'`
echo '[+] Downloading latests velociraptor Linux Binary'
wget -q -O velociraptor.bin ${VAR_GITHUB_LINUX}
echo '[+] Downloading latests velociraptor Windows Binary'
wget -q -O velociraptor_ORIG.msi ${VAR_GITHUB_WINDOW}

echo '[+] Running velociraptor config generate'
echo '[+] I use port 80 insted of 8000 for reasons ...'
chmod 777 velociraptor.bin
./velociraptor.bin config generate -i
sleep 1

echo '[+] Creating Deb package'
./velociraptor.bin --config server.config.yaml debian server --binary velociraptor.bin --output velociraptor.deb

echo '[+] Installing Deb package'
dpkg -i velociraptor.deb
sleep 5
systemctl status velociraptor_server

echo '[+] Repacking MSI with client.config.yaml'
./velociraptor.bin config repack --msi velociraptor_ORIG.msi client.config.yaml velociraptor_REPACKED.msi
