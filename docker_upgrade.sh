DURL=https://download.docker.com/linux/centos/7/x86_64/stable/Packages/
S1=${DURL}containerd.io-1.2.0-3.el7.x86_64.rpm
S2=${DURL}docker-ce-18.09.0-3.el7.x86_64.rpm
S3=${DURL}docker-ce-cli-18.09.0-3.el7.x86_64.rpm
yum install -y $S1 $S2 $S3
