# sabnzbd-docker
SABnzbd docker container built on top of CentOS7

docker run -d -p 8080:8080 -v /hostdir:/config -v /mnt:/mnt -e TMZN=America/Denver -e GUID=100 -e PUID=99 exist2resist/sabnzbd
