#!/bin/bash
# Time Capsule Proxy for SmallMediaHub - Updates and readme on https://github.com/leobrigassi/Time_Capsule_Proxy

# Check system requirements
arch=$(uname -m)
if ! [[ $arch == aarch64* ]] || [[ $arch == armv* ]]; then
    echo "System not supported. Please run from arm/aarch64 systems."
fi
if ! which qemu-system-aarch64 > /dev/null || ! which qemu-system-arm > /dev/null  ; then
  echo "Qemu not detected.
  apt install qemu-system-arm qemu-kvm
  Please install and try again."
  exit 1
fi
if ! which smbclient >/dev/null 2>&1; then
  echo "smbclient is required for this script to work correctly. 
  sudo apt install smbclient
  Please install and try again."
  exit 1
fi

# Prompt User Inputs
read -p "[INFO] The current script will install a local VM to allow mount of Time_Capsule as a NAS on linux with kernels 5.15 or above. 
Any previous setup will be OVERWRITTEN. Continue? (y/N): " INSTALL
if [[ "$INSTALL" =~ ^[Yy]$ ]]; then
    echo "[OK] installing..."
else
    echo "[INFO] Installation Aborted. No change has been performed."
    exit 1
fi

read -p "[INPUT] Time Capsule IPv4 (e.g. 192.168.1.10): " TC_IP
if [ -z "$TC_IP" ]; then
    echo "[ERROR] IPv4 required. Installation aborted"
    exit 1
fi
read -p "[INPUT] Time Capsule DISK name (e.g. Data): " TC_FOLDER
if [ -z "$TC_FOLDER" ]; then
    echo "[ERROR] DISK name is required. Installation aborted"
    exit 1
fi
read -p "[INPUT] Time Capsule USER: " TC_USER
TC_FSTAB_USER=$(if [ -z "$TC_USER" ]; then echo ""; else echo ",username=$TC_USER"; fi)
read -p "[INPUT] Time Capsule PASSWORD: " TC_PASSWORD
if [ -z "$TC_PASSWORD" ]; then
    echo "[ERROR] PASSWORD is required. Installation aborted"
    exit 1
fi

read -p "[INPUT] Do you want to enable mount at startup? (y/N): " STARTUP_MOUNT

# Define the media hub vars
TIME_CAPSULE_PROXY_PATH=$(readlink -f .)
TCP_ENV=$TIME_CAPSULE_PROXY_PATH/.env
PUID=$(id -u)
PGID=$(id -g)
TCP_SERVICE_TEMP_FILE=$TIME_CAPSULE_PROXY_PATH/time-capsule-proxy.service
TCP_SERVICE_PATH=/etc/systemd/system
TCP_SERVICE_MOUNT_FILE=$TIME_CAPSULE_PROXY_PATH/mount-time-capsule-proxy.sh

# Deflate VM
if [ ! -f "data.img" ]; then
  echo "[OK] Deflating VM disk..."
  sudo tar -xf timecapsule_proxy.tar.gz
fi

# stopping previously installed VMs and mounts
echo "[OK] Stopping previously mounted VM..."
sudo umount /srv/tc-proxy 2>/dev/null
echo "[OK] Waiting for VM to powerdown..."
if pgrep -f "mac=02:D2:46:5B:4E:84"; then
ssh root@localhost -i ./id_rsa_vm -o StrictHostKeyChecking=no -p50022 "poweroff"
while pgrep -f "mac=02:D2:46:5B:4E:84"; do
 sleep 5
done
echo "[OK] VM powered down."
fi

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

echo "[OK] VM up. Please wait..."
sleep 10
ssh root@localhost -i ./id_rsa_vm -o StrictHostKeyChecking=no -p50022 'echo -e "'$TC_PASSWORD'\n'$TC_PASSWORD'" | passwd' >/dev/null 2>&1
sudo mkdir -p /srv/tc-proxy >/dev/null
chmod +x mount-time-capsule-proxy.sh >/dev/null

# Configure /etc/fstab
comment="setup-vm-proxy-time-capsule.sh"
# ssh root@localhost -i ./id_rsa_vm -o StrictHostKeyChecking=no -p50022 "cp /etc/fstab /etc/fstab.bak && cp /etc/fstab /etc/fstab.new && sed -i '/$comment/d' /etc/fstab.new"
ssh root@localhost -i ./id_rsa_vm -o StrictHostKeyChecking=no -p50022 "cp /etc/fstab /etc/fstab.bak && cp /etc/fstab /etc/fstab.new && sed '6d' /etc/fstab.new" >/dev/null 2>&1
ssh root@localhost -i ./id_rsa_vm -o StrictHostKeyChecking=no -p50022 'echo "//'$TC_IP'/'$TC_FOLDER' /mnt/tc cifs _netdev,x-systemd.after=network-online.target'$TC_FSTAB_USER',password='$TC_PASSWORD',sec=ntlm,uid=0,vers=1.0,rw,file_mode=0777,dir_mode=0777 0 0 #_Run_setup-vm-proxy-time-capsule.sh_on_host_to_edit_this_line" | tee -a /etc/fstab.new && mv /etc/fstab.new /etc/fstab' >/dev/null 2>&1
ssh root@localhost -i ./id_rsa_vm -o StrictHostKeyChecking=no -p50022 'echo -e "'$TC_PASSWORD'\n'$TC_PASSWORD'" | smbpasswd -a root' >/dev/null 2>&1

# Configure mount-time-capsule-proxy.sh
if grep -q "#line_3_updated_on_first_run" < "$TCP_SERVICE_MOUNT_FILE"; then
  # Line 3 exists with the target string, delete it
sed -i 3d $TCP_SERVICE_MOUNT_FILE >/dev/null 2>&1
sed -i '3isource '$TCP_ENV' #line_3_updated_on_first_run' $TCP_SERVICE_MOUNT_FILE >/dev/null 2>&1
fi

#Save ENVs to file
if [ ! -f $TCP_ENV ]; then
    touch "$TCP_ENV"
else
    echo "# Environment variables for Time_Capsule_Proxy setup. Use Install.Time_Capsule_Proxy.sh to edit. Edit tcp.custom.env for custom variables" > $TCP_ENV
fi
echo "TIME_CAPSULE_PROXY_PATH=$TIME_CAPSULE_PROXY_PATH" >> $TCP_ENV
echo "TCP_ENV=$TCP_ENV" >> $TCP_ENV
echo "PUID=$PUID" >> $TCP_ENV
echo "PGID=$PGID" >> $TCP_ENV
echo "TC_IP=$TC_IP" >> $TCP_ENV
echo "TC_FOLDER=$TC_FOLDER" >> $TCP_ENV
echo "TC_FSTAB_USER=$TC_FSTAB_USER" >> $TCP_ENV
echo "TC_PASSWORD=$TC_PASSWORD" >> $TCP_ENV
echo "TIME_CAPSULE_PROXY_SERVICE=/etc/systemd/system/time-capsule-proxy.service" >> $TCP_ENV
echo "TCP_SERVICE_TEMP_FILE=$TCP_SERVICE_TEMP_FILE" >> $TCP_ENV
echo "TCP_SERVICE_MOUNT_FILE=$TCP_SERVICE_MOUNT_FILE" >> $TCP_ENV
echo "TCP_SERVICE_PATH=/etc/systemd/system" >> $TCP_ENV
TC_PASSWORD=""

# Test VM mount
if ssh root@localhost -i ./id_rsa_vm -o StrictHostKeyChecking=no -p50022 'mount -a && mount | grep -q //'$TC_IP'/'$TC_FOLDER''
then
    echo "[OK] VM running and connected to Time Capsule"
else
    echo "[ERROR] VM unable to connect to Time Capsule. Please check credentials and IPv4 and run install again"
    exit 1
fi

# Mounting samba share

echo "[OK] Initiating mounting sequence..."
touch connection.log 
echo "[OK] Showing logs from mount-time-capsule-proxy.sh..." > connection.log 
STOP_STRING="System up and running"

./mount-time-capsule-proxy.sh >/dev/null 2>&1
cleanup() {
    kill "$TAIL_PID" &>/dev/null
}
trap cleanup EXIT
sleep 1
tail -fq ./connection.log & >/dev/null 2>&1
TAIL_PID=$!
while ! grep -q "$STOP_STRING" < ./connection.log; do
    sleep 1
done
cleanup >/dev/null 2>&1

# Startup service setup
chmod +x enable-service-at-startup.sh
chmod +x vm-ssh.sh
chmod +x vm-up.sh
chmod +x vm-down.sh
if [[ "$STARTUP_MOUNT" =~ ^[Yy]$ ]]; then
    ./enable-service-at-startup.sh
else
    echo "[INFO] run ./enable-service-at-startup.sh to enable automatic mount at startup."
    echo "[INFO] run ./mount-time-capsule-proxy.sh to mount manually"
fi

echo "[OK] Process completed"