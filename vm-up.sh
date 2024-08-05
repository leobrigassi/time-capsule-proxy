#!/bin/bash
# Time Capsule Proxy for SmallMediaHub - Updates and readme on https://github.com/leobrigassi/time-capsule-proxy
# run VM

arch=$(uname -m)
if [[ $arch == x86_64* ]]; then
    sudo qemu-system-x86_64 \
    -M q35,accel=kvm \
    -cpu host \
    -m 256 \
    -boot order=c \
    -drive file=data.img,format=qcow2,if=virtio \
    -netdev user,id=net0,hostfwd=tcp::50022-:22,hostfwd=tcp::50445-:445 \
    -device virtio-net,netdev=net0,mac=$(cat qemu.mac) \
    -serial file:./vm.log \
    -daemonize \
    -display none
fi
if [[ $arch == aarch64* ]]; then
    sudo qemu-system-aarch64 \
    -M virt,accel=kvm \
    -cpu host \
    -m 256 \
    -drive file=data.img,format=qcow2,if=virtio \
    -bios uefi.rom \
    -device virtio-net-device,netdev=net0,mac=$(cat qemu.mac) \
    -netdev user,id=net0,hostfwd=tcp::50022-:22,hostfwd=tcp::50445-:445 \
    -serial file:./vm.log \
    -daemonize \
    -display none
fi

echo "[OK] Waiting for VM to boot..."
while ! sudo tail -f ./vm.log | grep -q "Welcome to Alpine Linux"; do
 sleep 5 
done

echo "[OK] VM up."