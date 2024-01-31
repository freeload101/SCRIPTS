# this script will auto install Splunk Universal Forwarder  universalforwarder in one of them rpm yum OS's 
# tested on Windows10 WSL

#wsl --update
#wsl --list --online
#wsl --unregister OracleLinux_9_1
#wsl --shutdown -d OracleLinux_9_1
#start /i cmd   /C "wsl --install -d OracleLinux_9_1 "
 
#CHOICE /T 5 /C y /CS /D y > %temp%/null
#wsl -d OracleLinux_9_1 -u root -e bash -c "yum -y update"
#wsl -d OracleLinux_9_1 -u root



# yum yum ! to run in the vm

yum update
cd /tmp
rpm -Uvh --nodeps `curl -s https://www.splunk.com/en_us/download/universal-forwarder.html\?locale\=en_us | grep -oP '"https:.*(?<=download).*x86_64.rpm"' |sed 's/\"//g' | head -n 1`
yum -y install splunkforwarder.x86_64
sleep 5



mkdir -p /opt/splunkforwarder/etc/apps/nwl_all_deploymentclient/local/
cd /opt/splunkforwarder/etc/apps/nwl_all_deploymentclient/local/

cat <<EOF> /opt/splunkforwarder/etc/apps/nwl_all_deploymentclient/local/app.conf
[install]
state = enabled

[package]
check_for_updates = false

[ui]
is_visible = false
is_manageable = false
EOF

cat <<EOF> /opt/splunkforwarder/etc/apps/nwl_all_deploymentclient/local/deploymentclient.conf
[deployment-client]
phoneHomeIntervalInSecs = 60
[target-broker:deploymentServer]
targetUri = XXXXXXXXXXXXXXXXXX:8089
EOF



cat <<EOF> /opt/splunkforwarder/etc/system/local/user-seed.conf
[user_info]
USERNAME = admin
PASSWORD = XXXXXXXXXXXXXXX
EOF



/opt/splunkforwarder/bin/splunk cmd btool deploymentclient list --debug

/opt/splunkforwarder/bin/splunk start --accept-license
