#!/bin/bash
# Time Capsule Proxy for SmallMediaHub - Updates and readme on https://github.com/leobrigassi/Time_Capsule_Proxy
source .env

if ! [ -d /run/systemd/system ]; then
    echo "[ERROR] systemctl not detected, script requires systemd."
    exit 1
fi

# Configure startup service
touch "$TCP_SERVICE_TEMP_FILE"
echo "[Unit]
Description=Mount Time_Capsule_Proxy and Restart Services
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart='$TCP_SERVICE_MOUNT_FILE'
RemainAfterExit=true

[Install]
WantedBy=multi-user.target" > "$TCP_SERVICE_TEMP_FILE"

echo "[INFO] Scanning for previously installed daemons..."
sudo systemctl stop Time_Capsule_Proxy.service >/dev/null 2>&1
sudo systemctl disable Time_Capsule_Proxy.service >/dev/null 2>&1
sudo rm $TCP_SERVICE_PATH/Time_Capsule_Proxy.service >/dev/null 2>&1
sudo cp $TCP_SERVICE_TEMP_FILE $TCP_SERVICE_PATH/Time_Capsule_Proxy.service >/dev/null 2>&1
sudo systemctl daemon-reload
sudo systemctl enable Time_Capsule_Proxy.service >/dev/null 2>&1
sudo systemctl start Time_Capsule_Proxy.service >/dev/null 2>&1

echo "[OK] Service enabled. Will lauch automatically when system starts up and network is detected online."