
'[+] Should be setup on https://localhost:8889 with login root and password password from when you setup the conf wizard  ! '
sleep 10

apt update
apt install curl -y

export   VAR_GITHUB_LINUX=`curl -s https://api.github.com/repos/Velocidex/velociraptor/releases/latest | grep -E "(.*download.*linux.*amd64\")" | tail -n 1 | awk '{print $2}'| sed -re 's/.*\"(.*).*\"/\1/g'`
export VAR_GITHUB_WINDOWS=`curl -s https://api.github.com/repos/Velocidex/velociraptor/releases/latest | grep -E "(.*download.*velociraptor-.*-windows-amd64\.msi\")" | tail -n 1 | awk '{print $2}'| sed -re 's/.*\"(.*).*\"/\1/g'`
echo '[+] Downloading latests velociraptor Linux Binary'
wget -q -O velociraptor.bin ${VAR_GITHUB_LINUX}
echo '[+] Downloading latests velociraptor Windows Binary'
wget -q -O velociraptor_ORIG.msi "${VAR_GITHUB_WINDOWS}"

echo '[+] Running velociraptor config generate'
echo '[+] I use port 80 insted of 8000 for reasons ...'
chmod 777 velociraptor.bin
./velociraptor.bin config generate -i 
# FIX FOR INO INTERACTIVE ./velociraptor.bin config generate> /tmp/config.yaml
# FIX ./velociraptor.bin --config /tmp/config.yaml config show --merge '{"Client":{"server_urls":["https://thebeast.rmccurdy.com:8000/"]}}' > /tmp/new_config.yaml


 
sleep 1
 

echo '[+] Creating Deb package'
./velociraptor.bin --config server.config.yaml debian server --binary velociraptor.bin --output velociraptor.deb

echo '[+] Installing Deb package'
dpkg -i velociraptor.deb
sleep 5
systemctl status velociraptor_server | tee out.txt

echo '[+] Repacking MSI with client.config.yaml'
./velociraptor.bin config repack --msi velociraptor_ORIG.msi client.config.yaml velociraptor_REPACKED.msi

echo '[+] Creating api.config.yaml for SOCFortress'
./velociraptor.bin --config server.config.yaml config api_client --name root --role administrator,api api.config.yaml

echo '[+] Updating server.config.yaml to listen on 0.0.0.0'
sed 's/bind_address: 127.0.0.1/bind_address: 0.0.0.0/g' /etc/velociraptor/server.config.yaml -ibak
systemctl restart velociraptor-server
systemctl restart velociraptor_server



echo '[+] Showing Service/Port info'
grep -B 3 port *.y*

sleep 8


echo '[+] Showing Service/Port LISTEN info'
netstat -ltpnd

'[+] Should be running on https://localhost:8889 with login root and password password ! '

 
echo '[+] get internet IP and update api.config.yaml with it'
export INTERNETIP=`ip route get 1.1.1.1  | awk '{print $7}' | head -n 1`
sed  -re "s/localhost:8001/$INTERNETIP/g"  api.config.yaml > .env
cp -R api.config.yaml /mnt/c/delete/ << /dev/null




