FROM exist2resist/centos7
MAINTAINER admin@dataadnstoragesolutions.com

COPY ./install.sh /tmp/install.sh
RUN chmod 755 /tmp/install.sh && /tmp/install.sh && rm -rf /tmp/*

VOLUME ["/config","/mnt"]
EXPOSE 8080
CMD ["/usr/local/bin/systemctl"]
