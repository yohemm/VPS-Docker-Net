#!/bin/sh
delimiter=${DELIMITER:-' '}
domain=''
sub_domains=''
echo "Info: All domain's varname : $DOMAINS"
echo "Info: The delimiter is : '$delimiter'"
IFS="$delimiter"
set -- $DOMAINS
date=$(date  +"%Y%m%d")
echo "Info: the current date is $date"
echo "Info: the current date is $NB_DAYS_FOR_RENEW"
for i in "$@"
do
    execution=0
    domain=`printenv $i`
    echo "printenv : ${i}_SD"
    sub_domains=`printenv "${i}_SD"`
    echo "======= verification of $domain's Certification ======="
    echo "Info: var's name domain is $FORCE_TO_RENEW"
    if [ -n "$domain" ]; then
        if [ $FORCE_TO_RENEW == 1 ];then
            echo "Info: force to renew"
            execution=1
        else
            if [ -d "/etc/letsencrypt/live/${domain/%\ */}" ]; then
                expiration=`openssl x509 -enddate -noout -in "/etc/letsencrypt/live/${domain/%\ */}/fullchain.pem"`
                echo "Info: expiration date is $expiration"
                if [ -n "$expiration" ]; then
                    enddate=`date -d "${expiration:9:-4}" +"%Y%m%d"`
                    echo "Info: the expiration date of $domain is $date"
                    nbDayToExpire=$(( ( $(date -d "${expiration:9:-4}" +%s) - $(date +%s) ) / 86400 ))
                    echo "Info:expire in $nbDayToExpire days"
                    if [ $nbDayToExpire -gt $NB_DAYS_FOR_RENEW ];then
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
    if [ $execution -eq 1 -o $execution -eq 2 ]; then
        echo "Execution: generate new certificat"
        if [ -n "$sub_domains" ];then

            echo "Info: certicat with sub domains"
            echo "certbot certonly -v --webroot --agree-tos --renew-by-default --preferred-challenges http-01 --email vaxelaire.yohem@gmail.com --webroot-path /var/www/certbot --cert-name -cert-name ${domain} -d ${sub_domains//[$delimiter]/ -d }"
            certbot certonly -v --webroot --agree-tos --renew-by-default --preferred-challenges http-01 --email vaxelaire.yohem@gmail.com --webroot-path /var/www/certbot --cert-name ${domain} -d ${sub_domains//[$delimiter]/ -d } 
        else
            echo "Info: no sub domains"
            echo "certbot certonly -v --webroot --agree-tos --renew-by-default --preferred-challenges http-01 --email vaxelaire.yohem@gmail.com --webroot-path /var/www/certbot -d ${domain} -n"
            certbot certonly -v --webroot --agree-tos --renew-by-default --preferred-challenges http-01 --email vaxelaire.yohem@gmail.com --webroot-path /var/www/certbot -d ${domain} -n

        fi
        /script/create-complentary-cert.sh $domain
    # elif [ $execution -eq 2 ]; then
    #     echo "Execution: renew the current certificat"
    #     /script/renew.sh $domain
    fi
    sub_domains=''
done

echo `ls -la /etc/letsencrypt/live/`