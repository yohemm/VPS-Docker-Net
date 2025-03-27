#!/bin/sh
cat /etc/letsencrypt/live/$1/privkey.pem /etc/letsencrypt/live/$1/fullchain.pem > /etc/letsencrypt/live/$1/mongo/mongod.pem
cat /etc/letsencrypt/live/$1/chain.pem > /etc/letsencrypt/live/$1/mongo/ca.crt