sudo mkfs.xfs /dev/vda
sudo wget http://192.168.31.202/static.network
sudo wget http://192.168.31.202/Ignition.json
sudo coreos-install -d /dev/vda -i Ignition.json http://192.168.31.202
