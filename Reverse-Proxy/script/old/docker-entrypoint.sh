#!/bin/sh
echo "=============== BEGIN reverse proxy ==============="
nginx -g "daemon off;" & NGINX_PID=$!
nginxActive=`ps aux | grep '[n]ginx'`
if [ "${#nginxActive}" -eq 0 ]; then
    echo "nginx is close"
    # exit 1
fi
echo "=============== CERTIFICATION ==============="
if [ -n "$DOMAINS" ]; then
    /script/cert-checker.sh
else
    echo "Error: env var \$DOMAINS is not set"
    exit 2
fi
echo "=============== CRON TASK ==============="
echo "Info: create renew cron"
echo "43 6 * * * /script/renew-all.sh" >> /etc/crontabs/vps
echo "=============== reload nginx ==============="
# nginx -s stop
while [ true ]; do
    nginxActive=`ps aux | grep '[n]ginx'`
    echo $nginxActive
    if [ "${#nginxActive}" -eq 0 ]; then
        echo "Error: nginx was closed"
        # exit 1
    fi
    kill -HUP $NGINX_PID
    # Sleep for 1 week
    sleep 10 &
    SLEEP_PID=$!
    # Wait for 1 week sleep or nginx
    wait -n "$SLEEP_PID" "$NGINX_PID"
done
