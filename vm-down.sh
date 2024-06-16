#!/bin/bash
if pgrep qemu; then
sudo umount /srv/tc-proxy
ssh root@localhost -i ./id_rsa_vm -o StrictHostKeyChecking=no -p50022 "poweroff"
while ! sudo tail -f ./vm.log | grep -q "reboot: Power down" >/dev/null; do
 sleep 5 
done
echo "[OK] TCProxy unmounted and VM powered down."
fi