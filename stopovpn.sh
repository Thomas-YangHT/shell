ps auxwww|grep openvpn|grep -v grep|awk '{print "kill -9 "$2}'|sh
