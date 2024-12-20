#!/usr/bin/env bash
#
#
set -e

CONTAINER_FIRST_STARTUP="CONTAINER_FIRST_STARTUP"

# if [ ! -e /speakers/speakers.json ] ; then
#     echo "init speakers..."
#     cp /m4t_server/speakers.tmpl.json /speakers/speakers.json
#     cp /m4t_server/female-0-100.wav /speakers/
# fi

# if command starts with an option, prepend omni-server
if [ "${1:0:1}" = '-' ]; then
    set -- ./serve.py "$@"
fi
# cd workspace


# if command app only, add use default args
if [ "$1" = './serve.py' ] && [ "$#" -eq 1 ]; then
    python -m tools.api_server     --listen 0.0.0.0:8999  ${LISTEN_ADDR}   --llama-checkpoint-path "checkpoints/fish-speech-1.5"     --decoder-checkpoint-path "checkpoints/fish-speech-1.5/firefly-gan-vq-fsq-8x1024-21hz-generator.pth" 
fi

exec "$@"
