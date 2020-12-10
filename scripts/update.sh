#!/bin/bash

## Get Updated RAR version
RAR=$(curl -s https://www.rarlab.com/download.htm | awk -F'/rar/' '/rarlinux-x64/ { print $2 } ')
RAR=$(echo $RAR | awk -F'\">' '{print $1}')

##Copy RAR
cd /tmp
wget -q https://rarlab.com/rar/$RAR
tar -zxf $RAR
cd /tmp/rar
cp -f ./rar /usr/local/sbin/
cp -f ./unrar /usr/local/sbin/

## Check Local Version
API=$(cat /config/sabnzbd_config.ini | grep ^api_key | awk '{print $3}')
INSTALLED=$(curl --silent http://localhost:8080/api?mode=version&output=json&apikey=${API})

## Check Online Version
CURRENT=$(curl --silent https://raw.githubusercontent.com/sabnzbd/sabnzbd/master/sabnzbd/version.py 2>&1 | grep "__version__ = " | awk -F'"' '{print $2}')

##Compare versions and update if necessary
if [[ $CURRENT == $INSTALLED ]]; then
  echo "Online Version matches installed version of SAB ignoring update."
else
  echo "Online Sab version is defferent, upgrading!"
  systemctl stop sabnzbd.service
  
  FOLDER="SABnzbd-"$CURRENT
  cd /tmp
  wget -q $DOWNLOAD 
  tar -zxf $FILE
  cd /tmp/$FOLDER
  cp -ru ./* /opt/sabnzbd/
  chown -R nobody:users /opt/sabnzbd
  pip install -q sabyenc --upgrade
  systemctl start sabnzbd.service
fi
##Cleanup
cd /
rm -rf /tmp/*