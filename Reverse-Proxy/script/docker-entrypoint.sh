#!/bin/sh

echo "=============== CERTIFICATION ==============="
checker_timer=600
readale_duration="$((checker_timer/60))"
if [ -n "$DOMAINS" ]; then
    while [ true ]; do
        /script/cert-checker.sh

        echo "Info: next check in $readale_duration minutes"
        sleep $checker_timer
    done
else
    echo "Error: env var \$DOMAINS is not set"
    exit 2
fi