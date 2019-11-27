#!/bin/bash
#Script for SAB docker container.

#Find the latest version of rar from website
RAR=$(curl -s https://www.rarlab.com/download.htm | awk -F'/rar/' '/rarlinux-x64/ { print $2 } ')
RAR=$(echo $RAR | awk -F'\">' '{print $1}')

#Remove files that can cause issues with systemd
cd /lib/systemd/system/sysinit.target.wants/ 
for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done; \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

#CONFIGURATION SCRIPTS
#Startup Script to Change UID and GUI in container
cat <<'EOT' > /usr/local/bin/start.sh
#!/bin/bash
TIMEZONE=${TZ:-America/Edmonton}
SYSTEMTZ=$(timedatectl | grep "Time zone" | awk -F':' '{ print $2 }' | awk -F'(' '{ print $1 }')

if [[ $SYSTEMTZ != $TIMEZONE ]];then
	timedatectl set-timezone $TIMEZONE
fi

USERID=${PUID:-99}
GROUPID=${GUID:-100}

groupmod -g $GROUPID users
usermod -u $USERID nobody
usermod -g $USERID nobody
usermod -d /home nobody
chown -R nobody:users /config /opt/sabnzbd

pip install -q sabyenc --upgrade
EOT

#Create Startup service for the above script
cat <<'EOT' > /etc/systemd/system/startup.service
[Unit]
Description=Startup Script that sets sab folder permissions.
Before=sabnzbd.service

[Service]
Type=simple
ExecStart=/usr/local/bin/start.sh
TimeoutStartSec=0

[Install]
WantedBy=default.target
EOT

#service file
cat <<'EOT' > /etc/systemd/system/sabnzbd.service
[Unit]
Description=SABnzbd Daemon

[Service]
Type=forking
User=nobody
Group=users
ExecStart=/usr/bin/python /opt/sabnzbd/SABnzbd.py --daemon --config-file=/config/sabnzbd_config.ini -s 0.0.0.0
GuessMainPID=no

[Install]
WantedBy=multi-user.target
EOT

#update script
cat <<'EOF' > /usr/local/bin/sabupdate.sh
#!/bin/bash
##Get Updated RAR version
RAR=$(curl -s https://www.rarlab.com/download.htm | awk -F'/rar/' '/rarlinux-x64/ { print $2 } ')
RAR=$(echo $RAR | awk -F'\">' '{print $1}')

##Copy RAR
cd /tmp
wget -q https://rarlab.com/rar/$RAR
tar -zxf $RAR
cd /tmp/rar
cp -f ./rar /usr/local/sbin/
cp -f ./unrar /usr/local/sbin/

##Update SAb
API_Key=`cat /config/sabnzbd.ini | grep ^api_key    | awk '{print $3}'`

systemctl stop sabnzbd.service



systemctl start sabnzbd.service

##Cleanup
rm -rf /tmp/*

##Update SAByenc
pip install -q sabyenc --upgrade
EOF

#crontab 
echo "0  0    * * *   root    /usr/local/bin/sabupdate.sh" >> /etc/crontab

#Import KEY
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

#Install prerequisites
yum install -y epel-release
yum install -y par2cmdline python-yenc python-cheetah wget tar git python-pip

#Install RAR
cd /tmp
wget -q https://rarlab.com/rar/$RAR
tar -zxf $RAR
cd /tmp/rar
cp ./rar /usr/local/sbin/
cp ./unrar /usr/local/sbin/

#Install pip upgrade sabyenc
pip install --upgrade pip
pip install -q sabyenc --upgrade

#Grab latest version of SAB
cd /opt
git clone https://github.com/sabnzbd/sabnzbd
cd /opt/sabnzbd
git checkout master
chown -R nobody:users /opt/sabnzbd
python tools/make_mo.py

#make config directory
mkdir -p /config
chmod -R 755 /config /usr/local/bin
chown -R nobody:users /config

#Clean up
cd /
yum clean all 

#enable service
systemctl enable startup.service
systemctl enable sabnzbd.service