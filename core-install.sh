sudo mkfs.xfs /dev/vda
#sudo wget http://192.168.31.253/coreos/static.network
sudo wget http://192.168.31.253/coreos/cloud-config.yaml
sudo coreos-install -d /dev/vda -c cloud-config.yaml -b http://192.168.31.253/coreos
