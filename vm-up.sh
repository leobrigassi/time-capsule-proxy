#!/bin/bash
# run VM
sudo qemu-system-aarch64 \
-M virt,accel=kvm \
-cpu host \
-m 256 \
-drive file=data.img,format=raw,if=virtio \
-bios uefi.rom \
-device virtio-net-device,netdev=net0,mac=$(cat qemu.mac) \
-netdev user,id=net0,hostfwd=tcp::50022-:22,hostfwd=tcp::50445-:445 \
-serial file:./vm.log \
-daemonize \
-display none


echo "[OK] Waiting for VM to boot..."
while ! sudo tail -f ./vm.log | grep -q "Welcome to Alpine Linux"; do
 sleep 5 
done

echo "[OK] VM up."