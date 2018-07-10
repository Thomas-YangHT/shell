cat <<EOF>/root/networkbr0.xml 
<network>  
<name>br0</name>    
<forward mode="bridge" />  
<interface dev="bond0" /> 
</network>
EOF

virsh net-define /root/networkbr0
virsh net-autostart br0
virsh net-start br0

