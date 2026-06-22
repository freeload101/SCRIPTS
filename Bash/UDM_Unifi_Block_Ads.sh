# bash <(curl -s https://github.com/freeload101/SCRIPTS/raw/master/Bash/UDM_Unifi_Block_Ads.sh)

# download python script 
wget 'https://github.com/freeload101/Python/raw/master/UDM_Unifi_Block_Ads.py'
chmod 777 UDM_Unifi_Block_Ads.py
# dump conf
./UDM_Unifi_Block_Ads.py > /etc/dnsmasq.d/dnsmasq.adblock.conf

# update /etc/dnsmasq.conf
sed -i 's/#conf-dir=\/etc\/dnsmasq.d\/,\*\.conf/conf-dir=\/etc\/dnsmasq.d\/,\*\.conf/g' /etc/dnsmasq.conf

# reload dnsmasq
/etc/init.d/dnsmasq force-reload

# test with nslookup doubleclick.net
echo 'test with https://d3ward.github.io/toolz/adblock.html' 
