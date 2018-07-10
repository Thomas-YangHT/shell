
pip install -U docker-py
cd ~
git clone http://git.trystack.cn/openstack/kolla-ansible -b stable/ocata
cd kolla-ansible
pip install .
#pip install . -i https://pypi.tuna.tsinghua.edu.cn/simple

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
cpu_mode = none
EOF
   
#vi /etc/kolla/globals.yml
#kolla_internal_vip_address: "192.168.31.203"


cd ~/shell;git pull
grep -Pv "^#|^$" globals.yml.99cloud >/etc/kolla/globals.yml
sed -i.ori 's/kolla_internal_vip_address:.*/kolla_internal_vip_address: "192.168.122.203"/' /etc/kolla/globals.yml
sed -i.ori 's/docker_registry: .*/docker_registry: "192.168.31.140:5000"/'  /etc/kolla/globals.yml

#for rabbitMQ:
echo "192.168.122.11 kolla kolla.yunwei.edu ">>/etc/hosts


kolla-genpwd
#编辑 /etc/kolla/passwords.yml
#keystone_admin_password: chenshake
sed -i.ori 's/keystone_admin_password:.*/keystone_admin_password: yunwei.edu/' /etc/kolla/passwords.yml

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
cd ~/kolla-ansible/tools/
#edit and modify init-runonce
#EXT_NET_CIDR='172.16.41.0/24'
#EXT_NET_RANGE='start=172.16.41.180,end=172.16.41.199'
#EXT_NET_GATEWAY='172.16.41.1'
sed -i.ori -e  's/EXT_NET_CIDR=.*/EXT_NET_CIDR='\''192.168.41.0\/24'\''/' \
-e  's/EXT_NET_RANGE=.*/EXT_NET_RANGE='\''start=192.168.41.180,end=192.168.41.199'\''/' \
-e  's/EXT_NET_GATEWAY=.*/EXT_NET_GATEWAY='\''192.168.41.1'\''/' \
 init-runonce
#yum remove python-ipaddress -y;yum install python-pip -y
pip install -U python-openstackclient python-neutronclient
./init-runonce


#reinstall:
docker stop `docker ps -q`
docker rm `docker ps -qa`
#docker volume prune
rm -rf /var/lib/docker/volumes/*
systemctl restart docker
rm -rf /etc/kolla/*
#multinode
cp -r /etc/kolla_multi/config /etc/kolla
cp /etc/kolla_multi/globals.yml /etc/kolla
cp /etc/kolla_multi/passwords.yml /etc/kolla
kolla-ansible deploy -i ./multinode
#allinone
cp -r /etc/kollabak/config /etc/kolla
cp /etc/kollabak/globals.yml /etc/kolla
cp /etc/kollabak/passwords.yml /etc/kolla
kolla-ansible deploy -i ./all-in-one


#配置文件：
more /etc/kolla/password.yml
more /etc/kollabak/config/nova/nova-compute.conf
more /etc/hostname 
kolla
more /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.31.11 kolla.yunwei.edu kolla
more /etc/kolla/globals.yml 
---
#kolla_base_distro: "centos"
kolla_install_type: "source"
openstack_release: "4.0.2.1"
kolla_internal_vip_address: "192.168.31.203"
docker_registry: "192.168.31.140:5000"
docker_namespace: "99cloud"
network_interface: "eth1"
neutron_external_interface: "eth2"
designate_backend: "bind9"
designate_ns_record: "sample.openstack.org"
#api_interface: "{{ network_interface }}"
tempest_image_id:
tempest_flavor_ref_id:
tempest_public_network_id:
tempest_floating_network_name:
#enable_haproxy: "no" 


#ceph: 
#为每个存储结点打标签：
parted /dev/vdb -s -- mklabel gpt mkpart KOLLA_CEPH_OSD_BOOTSTRAP 1 -1
#
cat >/etc/kolla/config/ceph.conf <<EOF
[global]
osd pool default size = 3
osd pool default min size = 2
EOF
#
hostnamectl set-hostname control0X

#cinder lvm
dd if=/dev/urandom of=/dev/vdb bs=512 count=64
pvcreate /dev/vdb
vgcreate cinder-volumes /dev/vdb