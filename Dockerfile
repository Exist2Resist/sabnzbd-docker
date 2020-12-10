FROM exist2resist/centos8:lite
LABEL maintainer="exist2resist@outlook.com"

ENV TZ='America/Edmonton' PUID=99 PGID=100

COPY ./install.sh /tmp/install.sh
RUN chmod 755 /tmp/install.sh && /tmp/install.sh && rm -rf /tmp/*

VOLUME ["/config","/mnt"]
EXPOSE 8080
CMD ["/usr/local/bin/systemctl"]
