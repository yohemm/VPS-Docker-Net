#!/bin/sh
delimiter=' '
domain=''
echo "Info: All domain's varname : $DOMAINS"
IFS="$delimiter"
set -- $DOMAINS
date=$(date  +"%Y%m%d")
echo "Info: the current date is $date"
for i in "$@"
do
    execution=0
    domain=`printenv $i`
    echo "======= verification of $domain's Certification ======="
    echo "Info: var's name domain is $i"
    if [ -n "$domain" ]; then
        if [ $FORCE_TO_RENEW -eq 1 ];then
            echo "Info: force to renew"
            execution=1
        else
            if [ -d "/etc/letsencrypt/live/${domain/%\ */}" ]; then
                expiration=`openssl x509 -enddate -noout -in "/etc/letsencrypt/live/${domain/%\ */}/fullchain.pem"`
                echo "Info: expiration date is $expiration"
                if [ -n "$expiration" ]; then
                    enddate=`date -d "${expiration:9:-4}" +"%Y%m%d"`
                    echo "Info: the expiration date of $domain is $date"
                    if [ $date -lt $enddate ];then
                        echo "Info: $domain is already certified, nothing to do"
                    else
                        echo "Info: $domain need to be renew"
                        execution=2
                    fi
                else
                    echo "Info: certicat expiration date is not set"
                    execution=1
                fi
            else
                echo "Info: $domain is not on this server"
                execution=1
            fi
        fi
    else
        echo "Warning: $i is not set or is empty."
    fi
    if [ $execution -eq 1 ]; then
        echo "Execution: generate new certificat"
        echo "${domain//[ ]/ -d }"
        certbot certonly -v --webroot --agree-tos --renew-by-default --preferred-challenges http-01 --email vaxelaire.yohem@gmail.com --webroot-path /var/www/certbot -d ${domain//[ ]/ -d } -n
        /script/create-complentary-cert.sh "${domain/%\ */}"
    elif [ $execution -eq 2 ]; then
        echo "Execution: renew the current certificat"
        /script/renew.sh $domain
    fi
done
# echo "$domains_declare"