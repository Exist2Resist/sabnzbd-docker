FROM rockylinux:8
LABEL maintainer="exist2resist@outlook.com"

ENV TZ='America/Edmonton' PUID=99 PGID=100

RUN useradd sabnzbd && usermod -u $PUID -g $PGID sabnzbd && groupmod -g $PGID users && usermod -d /home sabnzbd
COPY ./install.sh /tmp/install.sh
COPY ./bin/par2cmdline-turbo-v1.1.1-linux-amd64.xz /tmp/par2cmdline-turbo-v1.1.1-linux-amd64.xz
RUN chmod +x /tmp/install.sh && /tmp/install.sh && rm -f /tmp/install.sh 

VOLUME ["/config","/mnt"]
EXPOSE 8080

CMD ["/usr/local/bin/systemctl"]
