wget -O /etc/yum.repos.d/Centos7-Base-yunwei.repo    download.yunwei.edu/shell/Centos7-Base-yunwei.repo  
wget -O /etc/yum.repos.d/epel-yunwei.repo   download.yunwei.edu/shell/epel-yunwei.repo
wget -O /etc/yum.repos.d/rdo-release-yunwei.repo  download.yunwei.edu/shell/rdo-release-yunwei.repo
wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud  download.yunwei.edu/shell/RPM-GPG-KEY-CentOS-SIG-Cloud
cd /etc/yum.repos.d/;mv epel.repo ..;mv CentOS-Base.repo ..;mv rdo-release.repo ..;
yum repolist