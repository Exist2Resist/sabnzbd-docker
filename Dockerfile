FROM exist2resist/centos8:lite
LABEL maintainer="exist2resist@outlook.com"

ENV TZ='America/Edmonton' PUID=99 PGID=100

RUN useradd sabnzbd && usermod -u $PUID -g $PGID sabnzbd && groupmod -g $PGID users && usermod -d /home sabnzbd
COPY ./install.sh /tmp/install.sh
<<<<<<< HEAD
RUN chmod +x /tmp/install.sh && /tmp/install.sh && rm -f /tmp/install.sh 
=======
RUN chmod +X /tmp/install.sh && /tmp/install.sh && rm -f /tmp/install.sh 
>>>>>>> master

VOLUME ["/config","/mnt"]
EXPOSE 8080

<<<<<<< HEAD
CMD ["/usr/local/bin/systemctl"]
=======
CMD ["/usr/local/bin/systemctl"]
>>>>>>> master
