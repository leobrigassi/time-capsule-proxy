#!/bin/bash
# Time Capsule Proxy for SmallMediaHub - Updates and readme on https://github.com/leobrigassi/Time_Capsule_Proxy
source ./env #line_3_updated_on_first_run
cd $TIME_CAPSULE_PROXY_PATH
# Log file path
LOG_FILE="$TIME_CAPSULE_PROXY_PATH/connection.log"
touch $LOG_FILE
sudo chmod 770 $LOG_FILE

# Function to check SMB share accessibility
check_smb_share() {
    smbclient //localhost/tc-proxy -U root%$TC_PASSWORD --port=50445 -c 'exit' > /dev/null 2>&1
    return $?
}

# Function to restart the Time_Capsule_Proxy container
restart_TCP_container() {
    ssh root@localhost -i ./id_rsa_vm -o StrictHostKeyChecking=no -p50022 "reboot"
    if pgrep -f "mac=02:D2:46:5B:4E:84"; then
        while pgrep -f "mac=02:D2:46:5B:4E:84"; do
            sleep 5
        done
    fi
}

# Function to get current timestamp
get_timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

# Function to write log messages
log_message() {
    echo "$(get_timestamp): $1" >> "$LOG_FILE"
}

# Function to load VM
loadVM() {
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
}

# Retry logic with a timeout
MAX_RETRIES=20
RETRY_INTERVAL=60
retry_count=0
failed_attempts=0

log_message "[OK] Initiating Time_Capsule_Proxy mount process..."
cd $TIME_CAPSULE_PROXY_PATH

if pgrep -f "mac=02:D2:46:5B:4E:84"; then
    loadVM 
fi




while [ $retry_count -lt $MAX_RETRIES ]; do
    if check_smb_share; then
        log_message "[OK] VM samba share is accessible."
        break
    else
        retry_count=$((retry_count + 1))
        failed_attempts=$((failed_attempts + 1))
        log_message "[INFO] Failed to access VM samba share. Attempt $retry_count/$MAX_RETRIES."
        if [ $failed_attempts -eq 5 ]; then
            log_message "[INFO] Restarting time-capsule-proxy container..."
            restart_TCP_container
            sleep 10
        fi
        if [ $failed_attempts -eq 10 ]; then
            log_message "[ERROR] Container taking very long to load. Killing and restarting time-capsule-proxy container..."
            sudo kill $(pgrep -f "mac=02:D2:46:5B:4E:84")
            sleep 5
            loadVM
        fi
        sleep $RETRY_INTERVAL
    fi
done

# Verify mount
if ! mountpoint -q /srv/tc-proxy; then
    log_message "[OK] /srv/tc-proxy is not mounted. Remounting..."
    sudo umount -l /srv/tc-proxy  > /dev/null 2>&1
    sudo mount -t cifs //localhost/tc-proxy /srv/tc-proxy/ -o password="$TC_PASSWORD""$TC_FSTAB_USER",rw,uid=$PUID,iocharset=utf8,vers=3.0,nofail,file_mode=0775,dir_mode=0775,port=50445 >> "$LOG_FILE"
fi
log_message "[DONE] System up and running"