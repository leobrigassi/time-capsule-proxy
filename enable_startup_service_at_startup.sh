#!/bin/bash

source .env

# Configure startup service
touch "$TCP_SERVICE_TEMP_FILE"
echo "[Unit]
Description=Mount Time_Capsule_Proxy.sh and Restart Services
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=$TCP_SERVICE_MOUNT_FILE
RemainAfterExit=true

[Install]
WantedBy=default.target" > "$TCP_SERVICE_TEMP_FILE"

echo "[INFO] Scanning for previously installed daemons..."
sudo systemctl stop Time_Capsule_Proxy.service >/dev/null
sudo systemctl disable Time_Capsule_Proxy.service >/dev/null
sudo rm $TCP_SERVICE_PATH/Time_Capsule_Proxy.service >/dev/null
sudo cp $TCP_SERVICE_TEMP_FILE $TCP_SERVICE_PATH/Time_Capsule_Proxy.service >/dev/null
sudo systemctl daemon-reload
sudo systemctl enable Time_Capsule_Proxy.service >/dev/null
sudo systemctl start Time_Capsule_Proxy.service >/dev/null


# Test VM mount
./mount_Time_Capsule_Proxy.sh
if ssh root@localhost -i ./id_rsa_vm -o StrictHostKeyChecking=no -p50022 'mount -a && mount | grep -q //'$TC_IP'/'$TC_FOLDER''
then
    echo "[OK] VM running and /srv/tc-proxy mounted correctly"
else
    echo "[ERROR] unable to mount. Please check credentials in .env file and run install again"
fi