/usr/sbin/nginx -c /uwsgi/nginx.conf
uwsgi /uwsgi/testflk.ini
while [[ true ]]; do 
    sleep 1 
done