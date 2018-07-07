 
 firewall-cmd --zone=work --add-interface=eth1 --permanent
 firewall-cmd --zone=work --add-interface=eth2 --permanent
 firewall-cmd --zone=work --add-interface=eth3  --permanent
 firewall-cmd --zone=work --add-interface=bond0  --permanent
 firewall-cmd --zone=work --add-interface=br0    --permanent
 firewall-cmd --zone-work --add-port 0-65535/tcp --permanent
 firewall-cmd --zone-work --add-port 0-65535/udp --permanent
 firewall-cmd --zone-work --add-port 0-65535/tcp 
 firewall-cmd --zone-work --add-port 0-65535/udp 
  
firewall-cmd --zone-public --add-interface=eth1 --permanent

firewall-cmd --get-active-zones
firewall-cmd --zone=public --list-all
firewall-cmd --zone=work --list-all

