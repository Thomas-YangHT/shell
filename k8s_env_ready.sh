echo "-------prepare system remove old, ssh-kengen,selinux,bridge...------"
yum -y remove kubernetes*  docker* docker-selinux etcd flannel
#in vm1
#ssh-keygen 
#ssh-copy-id -i /root/.ssh/id_rsa.pub  root@vm2
#scp -rp k8s_images vm2:/root
#in vm2
#ssh-keygen 
#ssh-copy-id -i /root/.ssh/id_rsa.pub root@vm1 
systemctl stop firewalld && systemctl disable firewalld 
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
grep SELINUX=disabled /etc/selinux/config
setenforce 0
getenforce 
#Disabled
echo "
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
" >> /etc/sysctl.conf
sysctl -p
echo "-------docker load ...------"
tar -xjvf k8s_images.tar.bz2 
cd k8s_images
#https://download.docker.com/linux/centos/7/x86_64/stable/Packages/
yum -y localinstall docker-ce-*
#curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://a58c8480.m.daocloud.io
rm -rf  /var/lib/docker/
systemctl start docker && systemctl enable docker
docker --version

echo "-------docker load ...------"
cd k8s_images/docker_images/
for i in $(ls *.tar);do docker load < $i;done
cd ..
docker load < kubernetes-dashboard_v1.8.1.tar 
echo "-------rpm -ivh kubeadm...------"
cd /root/k8s_images/
rpm -ivh socat-1.7.3.2-2.el7.x86_64.rpm
rpm -ivh kubernetes-cni-0.6.0-0.x86_64.rpm \
   kubelet-1.9.9-9.x86_64.rpm  \
   kubectl-1.9.0-0.x86_64.rpm  \
   kubeadm-1.9.0-0.x86_64.rpm
rpm -qa |grep kube
rpm -qa |grep socat
echo "-------start kubelet------"
swapoff -a
grep -i 'cgroupfs' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
#Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=cgroupfs"
sed -i 's/cgroup-driver=systemd/cgroup-driver=cgroupfs/'  /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
# systemctl daemon-reload
systemctl enable kubelet && systemctl start kubelet
#==========================admin start===========================================================
echo "-------kubeadm init------"
kubeadm init --kubernetes-version=v1.9.0 --pod-network-cidr=10.244.0.0/16 
echo "-------kubectl version------"
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bash_profile
cd ~
source  .bash_profile
kubectl version
echo "-------flannel------"
#wget https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
cd k8s_images
kubectl create -f kube-flannel.yml
#=========================admin stop============================================================
echo "-------node join------"
#swapoff  -a
#kubeadm join --token 1c4596.b1a3723424b4c504 192.168.100.62:6443 --discovery-token-ca-cert-hash sha256:90e8121dc67ab741e1744f2ca0636cd1bafbaebf15d10013013d03d2dea1930f

#----------------------------------------
kubectl get pod --all-namespaces
kubectl create -f kubernetes-dashboard.yaml 
echo 'admin,admin,2' > /etc/kubernetes/pki/basic_auth_file
sed -i.ori '/authorization-mode=Node,RBAC/a \    - --basic_auth_file=/etc/kubernetes/pki/basic_auth_file' /etc/kubernetes/manifests/kube-apiserver.yaml
grep 'auth' /etc/kubernetes/manifests/kube-apiserver.yaml
#    - --enable-bootstrap-token-auth=true
#    - --authorization-mode=Node,RBAC
#    - --basic_auth_file=/etc/kubernetes/pki/basic_auth_file 
#kubectl apply -f /etc/kubernetes/manifests/kube-apiserver.yaml
#kubectl delete pod kube-apiserver --namespace=kube-system
#kubectl replace ?
kubectl create clusterrolebinding  \
  login-on-dashboard-with-cluster-admin  \
  --clusterrole=cluster-admin --user=admin
kubectl get clusterrolebinding/login-on-dashboard-with-cluster-admin -o yaml
curl --insecure https://kube-node2:6443 -basic -u admin:admin  

#curl --insecure https://10.104.204.144:443
#firefox:  https://192.168.100.62:32666
kubectl get svc --all-namespaces
kubectl get pod --all-namespaces
kubectl get ep  --all-namespaces
kubectl get rs  --all-namespaces
kubectl get rc  --all-namespaces
kubectl get deploy  --all-namespaces
kubectl describe --namespace=kube-system svc kubernetes-dashboard
kubectl describe --namespace=kube-system po pod名称
