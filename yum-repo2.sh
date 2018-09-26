cd /etc/yum.repos.d/;mv * ..
curl -o /etc/yum.repos.d/Centos7-Base-yunwei.repo    download.yunwei.edu/config/Centos7-Base-yunwei.repo  
curl -o /etc/yum.repos.d/epel-yunwei.repo   download.yunwei.edu/config/epel-yunwei.repo
curl -o /etc/yum.repos.d/rdo-release-yunwei.repo  download.yunwei.edu/config/rdo-release-yunwei.repo
curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud  download.yunwei.edu/config/RPM-GPG-KEY-CentOS-SIG-Cloud
curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7  download.yunwei.edu/config/RPM-GPG-KEY-EPEL-7
yum repolist