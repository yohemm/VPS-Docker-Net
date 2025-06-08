#!/bin/sh
cat /etc/letsencrypt/live/$1/fullchain.pem /etc/letsencrypt/live/$1/privkey.pem > /etc/letsencrypt/live/$1/mongodb.pem
cat /etc/letsencrypt/live/$1/fullchain.pem > /etc/letsencrypt/live/$1/mongodb-CA.cert