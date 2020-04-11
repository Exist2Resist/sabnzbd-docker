#!/bin/bash
#Set proper time zone
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/$TZ /etc/localtime
#passes

##CONFIGURATION SCRIPTS
##Startup Script to Change UID and GUI in container
cat <<'EOT' > /usr/local/bin/start.sh
#!/bin/bash
#TIMEZONE=${TZ:-America/Edmonton}
#SYSTEMTZ=$(timedatectl | grep "Time zone" | awk -F':' '{ print $2 }' | awk -F'(' '{ print $1 }')

rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/$TZ /etc/localt

USERID=${PUID:-99}
GROUPID=${PGID:-100}

groupmod -g $GROUPID users
usermod -u $USERID nobody
usermod -g $USERID nobody
usermod -d /home nobody
chown -R nobody:users /config /opt/sabnzbd
chmod -R 755 /config

pip3 install -q sabyenc --upgrade
EOT
#passes

##Create Startup service for the above script
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
#passes

##SABnzbd service file
cat <<'EOT' > /etc/systemd/system/sabnzbd.service
[Unit]
Description=SABnzbd Daemon

[Service]
Type=forking
User=nobody
Group=users
ExecStart=/usr/bin/python3 /opt/sabnzbd/SABnzbd.py --daemon --config-file=/config/sabnzbd_config.ini -s 0.0.0.0
GuessMainPID=no

[Install]
WantedBy=multi-user.target
EOT
#passes

##Import KEY
#curl https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official -o /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Official
#rpm --import /etc/pki/rpm-gpg/*
#rpm gpg check is broken

##Install prerequisites
dnf install -y epel-release --nogpgcheck
dnf install -y par2cmdline wget gcc git p7zip p7zip-plugins unzip --nogpgcheck

#Clone sabnzbd and install requirements
cd /opt 
git clone https://github.com/sabnzbd/sabnzbd.git
pip3 install -r /opt/sabnzbd/requirements.txt -U

##Find the latest version of RAR
RAR=$(curl -s https://www.rarlab.com/download.htm | awk -F'/rar/' '/rarlinux-x64/ { print $2 } ')
RAR=$(echo $RAR | awk -F'\">' '{print $1}')

##Install RAR
cd /tmp
wget -q https://rarlab.com/rar/$RAR
tar -zxf $RAR
cd /tmp/rar
cp ./rar /usr/local/sbin/
cp ./unrar /usr/local/sbin/

##Find latest version of SAB
#DOWNLOAD=$(curl --silent https://sabnzbd.org/downloads 2>&1 | grep "Linux" | awk -F'"' '/download-link-src/ { print $4 } ')
#CURRENT=$(echo $DOWNLOAD | awk -F'/' ' { print $8 } ')
#FOLDER="SABnzbd-$CURRENT"
#FILE=$(echo $DOWNLOAD | awk -F'/' ' { print $9 } ')

#Grab latest version of SAB
#cd /tmp
#wget -q $DOWNLOAD
#tar -zxf $FILE
#cd /tmp/$FOLDER
#mkdir /opt/sabnzbd/
#cp -ru ./* /opt/sabnzbd/
#chown -R nobody:users /opt/sabnzbd
#pip install -q sabyenc --upgrade
#python tools/make_mo.py

#make config directory
mkdir -p /config
chmod -R 755 /config /usr/local/bin
chown -R nobody:users /config

#Clean up
cd /
rm -rf /tmp/*
dnf clean all 

#enable service
systemctl enable startup.service
systemctl enable sabnzbd.service
