#!/bin/bash
# Time Capsule Proxy for SmallMediaHub - Updates and readme on https://github.com/leobrigassi/time-capsule-proxy

# stopping previously installed VMs and mounts
echo "[OK] Stopping previously mounted VM..."
sudo umount /srv/tc-proxy 2>/dev/null
echo "[OK] Waiting for VM to powerdown..."
if pgrep -f "mac=02:D2:46:5B:4E:84"; then
ssh root@localhost -i ./id_rsa_vm -o StrictHostKeyChecking=no -p50022 "poweroff"
LOOP_COUNT=0
    while pgrep -f "mac=02:D2:46:5B:4E:84" && [[ $LOOP_COUNT -lt 10 ]]; do
    sleep 5
    LOOP_COUNT=$((LOOP_COUNT + 1))
    done
        if [[ $LOOP_COUNT -lt 10 ]]; then
        echo "[OK] VM powered down."
        else
        sudo kill $(pgrep -f "mac=02:D2:46:5B:4E:84")
        echo "[ERROR] Failed to power off gracefully. VM process killed forcefully"
        fi
else
    echo "[OK] VM already down."
fi

source ./mount-time-capsule-proxy.sh


