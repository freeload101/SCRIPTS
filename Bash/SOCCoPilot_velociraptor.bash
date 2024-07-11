apt update
apt install curl -y

export VAR_GITHUB=`curl -s https://api.github.com/repos/Velocidex/velociraptor/releases | grep -E "(.*download.*linux.*64)" | head -n 1 | awk '{print $2}'| sed -re 's/.*\"(.*).*\"/\1/g'`
 

wget -q -O velociraptor.bin ${VAR_GITHUB}

chmod 777 velociraptor.bin
./velociraptor.bin config generate -i
sleep 5
./velociraptor.bin --config server.config.yaml debian server --binary velociraptor.bin --output velociraptor.deb
sleep 5
dpkg -i velociraptor.deb
sleep 5
systemctl status velociraptor_server
