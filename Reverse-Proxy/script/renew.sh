#!/bin/sh
certbot renew --cert-name "$1" --force-renewal
/script/create-complentary-cert.sh "$1"