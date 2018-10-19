 git clone https://github.com/coreos/coreos-vagrant
 cd coreos-vagrant
 cp user-data.sample user-data
 curl https://discovery.etcd.io/new?size=3
 vi user-data 
 #add at below etcd2: discovery: https://discovery.etcd.io/a078d2a6b509d8026e20d6ea53e52295
 
 cp config.rb.sample config.rb