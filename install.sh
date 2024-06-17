#!/bin/bash
# Time Capsule Proxy for SmallMediaHub - Updates and readme on https://github.com/leobrigassi/Time_Capsule_Proxy
if [ "$(basename $(pwd))" == "Time_Capsule_Proxy" ]; then
    echo "Extracting in Time_Capsule_Proxy directory."
else
    echo "Creating Time_Capsule_Proxy directory."
    mkdir -p Time_Capsule_Proxy &&
    cd Time_Capsule_Proxy >/dev/null 2>&1
fi
wget https://github.com/leobrigassi/Time_Capsule_Proxy/archive/refs/heads/main.tar.gz &&
tar -xzf main.tar.gz --strip-components=1 && rm main.tar.gz &&
chmod +x setup-time-capsule-proxy.sh && source ./setup-time-capsule-proxy.sh