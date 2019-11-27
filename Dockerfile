FROM centos:7
MAINTAINER exist2resist

COPY ./install.sh /tmp/
RUN chmod 755 /tmp/install.sh && /tmp/install.sh && rm -rf /tmp/*

VOLUME ["/config","/mnt"]
EXPOSE 8080
CMD ["/usr/sbin/init"]