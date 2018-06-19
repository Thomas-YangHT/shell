
pip install -U docker-py
pip install kolla-ansible
#CentOS
cp -r /usr/share/kolla-ansible/etc_examples/kolla /etc/kolla
cp /usr/share/kolla-ansible/ansible/inventory/* .

#pull 镜像 方法一

#kolla-ansible pull
#https://hub.docker.com/u/kolla/
#docker search kolla|grep -P "^kolla/centos.*"|awk '{print "docker pull "$1":ocata"}'|sh

#镜像准备 方法二：
#docker load -i 
mkdir -p /etc/kolla/config/nova/
cat << EOF > /etc/kolla/config/nova/nova-compute.conf
[libvirt]
virt_type=qemu
EOF

#vi /etc/kolla/globals.yml
#kolla_internal_vip_address: "192.168.31.203"
sed -i.ori 's/kolla_internal_vip_address:.*/kolla_internal_vip_address: "192.168.31.203"/' /etc/kolla/globals.yml

kolla-ansible prechecks -i ./all-in-one
#Deploy OpenStack.
kolla-ansible deploy -i ./all-in-one
#List the running containers.
docker ps -a
#Generate the admin-openrc.sh file. The file will be created in /etc/kolla/ directory.
kolla-ansible post-deploy
#To test your deployment, run the following commands to initialize the network with a glance image and neutron networks.
source /etc/kolla/admin-openrc.sh
#centOS
cd /usr/share/kolla
./init-runonce

