#!/bin/env bash
#
# Created by dev on 18/09/28.
#

echo "
[Unit]
Description=Omnigram M4t Service
Wants=network-online.target
After=network.target network-online.target


[Service]
Type=simple
WorkingDirectory=/opt/m4t_server
ExecStart=${MY_PYTHON_PATH}/python ./serve.py --host 0.0.0.0 --port 50051 --model-path ${MY_MODEL_PATH}
Restart=on-failure
StandardOutput=null

[Install]
WantedBy=multi-user.target
" > m4t-server.service

cp m4t-server.service /usr/lib/systemd/system/

systemctl daemon-reload
systemctl enable m4t-server.service
systemctl start m4t-server.service
systemctl status m4t-server.service