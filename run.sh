#!/bin/bash

echo "Waiting for Redis…"
while ! nc -zw 1 redis 6379; do :; done

echo "Waiting for Postgres…"
while ! nc -zw 1 postgres 5432; do :; done

function wait_for_sentry {
    echo "Waiting for Sentry…"
    while ! nc -zw 1 sentry 9000; do :; done
}

if [ "$1" = "worker" ]; then
    wait_for_sentry
    sleep 10
    /bin/bash /entrypoint.sh sentry run worker
elif [ "$1" = "cron" ]; then
    wait_for_sentry
    sleep 10
    /bin/bash /entrypoint.sh sentry run cron
else
    mkdir -p /container_status
    if [ ! -f /container_status/setup ] ; then
        /bin/bash /entrypoint.sh sentry upgrade --noinput
        /bin/bash /entrypoint.sh sentry createuser \
            --email admin@example.com \
            --password fnordx \
            --superuser \
            --no-input
        touch /container_status/setup
    fi
    /bin/bash /entrypoint.sh sentry run web
fi