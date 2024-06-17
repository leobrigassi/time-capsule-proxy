#!/bin/bash
# Time Capsule Proxy for SmallMediaHub - Updates and readme on https://github.com/leobrigassi/time-capsule-proxy
if [ "$(basename $(pwd))" == "time-capsule-proxy" ]; then
    echo "Extracting in time-capsule-proxy directory."
else
    echo "Creating Time_Capsule_Proxy directory."
    mkdir -p time-capsule-proxy &&
    cd time-capsule-proxy >/dev/null 2>&1
fi

downloadTC() {
wget https://github.com/leobrigassi/Time_Capsule_Proxy/archive/refs/heads/main.tar.gz >2 /dev/null &&
tar -xzf main.tar.gz --strip-components=1 && rm main.tar.gz >2 /dev/null &&
chmod +x setup-time-capsule-proxy.sh
} 

downloadTC >/dev/null 2>&1
