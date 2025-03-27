#!/bin/sh

echo "=============== CERTIFICATION ==============="
checker_timer=$((3600 * $TIMER_HOURS_RENEW))
if [ -n "$DOMAINS" ]; then
    while [ true ]; do
        /script/cert-checker.sh

        echo "Info: next check in $TIMER_HOURS_RENEW hours"
        sleep $checker_timer
    done
else
    echo "Error: env var \$DOMAINS is not set"
    exit 2
fi