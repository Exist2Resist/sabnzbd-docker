# sabnzbd-docker
SABnzbd docker container built on top of rockylinux:8

docker run -d -p 8080:8080 -v /hostdir:/config -v /mnt:/mnt -e TZ=America/Edmonton -e GUID=100 -e PGID=99 exist2resist/sabnzbd

