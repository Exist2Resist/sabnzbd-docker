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