#!/bin/bash
#Set proper time zone
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/$TZ /etc/localtime

##CONFIGURATION SCRIPTS
##Startup Script to Change UID and GUI in container
cat <<'EOT' > /usr/local/bin/start.sh
#!/bin/bash
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/$TZ /etc/localt

#USERID=${PUID:-99}
#GROUPID=${PGID:-100}

groupmod -g $PGID users
usermod -u $PUID -g $PGID sabnzbd
usermod -d /home sabnzbd
chown -R sabnzbd:users /config /opt/sabnzbd
chmod -R 755 /config
EOT
chmod +x /usr/local/bin/start.sh

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
WantedBy=multi-user.target
EOT

##SABnzbd service file
cat <<'EOT' > /etc/systemd/system/sabnzbd.service
[Unit]
Description=SABnzbd Daemon
After=startup.service

[Service]
Type=forking
User=sabnzbd
Group=users
ExecStart=/usr/bin/python3 /opt/sabnzbd/SABnzbd.py --daemon --config-file=/config/sabnzbd_config.ini -s 0.0.0.0
GuessMainPID=no

[Install]
WantedBy=multi-user.target
EOT

##Install prerequisites
dnf install -y epel-release --nogpgcheck && dnf clean all -y
dnf install -y python39 par2cmdline automake wget gcc git p7zip p7zip-plugins unzip --nogpgcheck && dnf clean all -y

##Install par2cmdline-turbo
git clone https://github.com/animetosho/par2cmdline-turbo.git
cd par2cmdline-turbo
aclocal
automake --add-missing
autoconf
./configure
make
make install
cd .. && rm -rf par2cmdline-turbo

#Clone sabnzbd and install requirements
cd /opt 
git clone https://github.com/sabnzbd/sabnzbd.git
cd /opt/sabnzbd
git checkout master
python3 -m pip install --upgrade pip
python3 -m pip install -r /opt/sabnzbd/requirements.txt -U

##Multi Language support
python3 tools/make_mo.py

##Find the latest version of RAR
RAR=$(curl -s https://www.rarlab.com/download.htm | awk -F'/rar/' '/rarlinux-x64/ { print $2 } ' | awk -F'\">' 'END {print $1}')

##Install RAR
cd /tmp
wget -q https://rarlab.com/rar/$RAR
tar -zxf $RAR
cp /tmp/rar/rar /usr/local/sbin/
cp /tmp/rar/unrar /usr/local/sbin/
rm -rf /tmp/*

# Get systemd
wget https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py -O /usr/local/bin/systemctl
chmod 755 /usr/local/bin/systemctl

#make config directory
mkdir -p /config
chmod -R 755 /config /usr/local/bin
chown -R nobody:users /config

#enable service
systemctl enable startup.service
systemctl enable sabnzbd.service
