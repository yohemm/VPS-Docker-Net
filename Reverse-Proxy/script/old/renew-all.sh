#!/bin/sh
delimiter=' '
domain=''
DOMAINS=${DOMAINS:-"example1.com example2.com"}
echo "renew : $DOMAINS"
IFS="$delimiter"
set -- $DOMAINS

for i in "$@"
do
    domain=`printenv $i`
    echo "======= $domain vérify Certification ======="
    /script/renew.sh $domain
done

nginx -s reload