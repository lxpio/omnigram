#!/usr/bin/env bash
#
#
set -e

CONTAINER_FIRST_STARTUP="CONTAINER_FIRST_STARTUP"

if [ ! -e /speakers/speakers.json ] ; then
    echo "init speakers..."
    cp /m4t_server/speakers.tmpl.json /speakers/speakers.json
    cp /m4t_server/female-0-100.wav /speakers/
fi

# if command starts with an option, prepend omni-server
if [ "${1:0:1}" = '-' ]; then
    set -- ./serve.py "$@"
fi
# cd workspace


# if command app only, add use default args
if [ "$1" = './serve.py' ] && [ "$#" -eq 1 ]; then
    exec ./serve.py  --host "0.0.0.0"  --port ${SERVER_PORT} --model-path ${MODEL_PATH} 
fi

exec "$@"
