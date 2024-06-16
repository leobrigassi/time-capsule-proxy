#!/bin/bash
# Time Capsule Proxy for SmallMediaHub - Updates and readme on https://github.com/leobrigassi/Time_Capsule_Proxy
source /srv/dev-disk-by-uuid-47da846a-d1a2-4ea6-816f-b33cc9e6c7e7/appdata/testTCP/Time_Capsule_Proxy/.env #line_3_updated_on_first_run

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
    sudo docker restart Time_Capsule_Proxy
}

# Function to get current timestamp
get_timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

# Function to write log messages
log_message() {
    echo "$(get_timestamp): $1" >> "$LOG_FILE"
}

# Retry logic with a timeout
MAX_RETRIES=20
RETRY_INTERVAL=60
retry_count=0
failed_attempts=0

log_message "[OK] Initiating Time_Capsule_Proxy mount process..."

while [ $retry_count -lt $MAX_RETRIES ]; do
    if check_smb_share; then
        log_message "[OK] VM samba share is accessible."
        break
    else
        retry_count=$((retry_count + 1))
        failed_attempts=$((failed_attempts + 1))
        log_message "[INFO] Failed to access VM samba share. Attempt $retry_count/$MAX_RETRIES."
        if [ $failed_attempts -eq 5 ]; then
            log_message "[INFO] Restarting Time_Capsule_Proxy container..."
            restart_TCP_container
            sudo docker-compose -f $TIME_CAPSULE_PROXY_PATH/docker-compose.yml up -d
        fi
        if [ $failed_attempts -eq 10 ]; then
            log_message "[ERROR] Container taking very long to load. Restarting Time_Capsule_Proxy container..."
            restart_TCP_container
            sudo docker-compose -f $TIME_CAPSULE_PROXY_PATH/docker-compose.yml up -d
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
