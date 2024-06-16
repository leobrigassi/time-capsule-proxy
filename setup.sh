#!/bin/bash
# Time Capsule Proxy for SmallMediaHub - Updates and readme on https://github.com/leobrigassi/Time_Capsule_Proxy
if [ "$(basename $(pwd))" == "Time_Capsule_Proxy" ]; then
    echo "Extracting in Time_Capsule_Proxy directory."
else
    echo "Creating Time_Capsule_Proxy directory."
    mkdir -p Time_Capsule_Proxy &&
    cd Time_Capsule_Proxy
fi
curl -# -sSL https://github.com/leobrigassi/Time_Capsule_Proxy/archive/refs/heads/main.zip > Time_Capsule_Proxy.zip && 
unzip -j Time_Capsule_Proxy.zip && 
rm Time_Capsule_Proxy.zip && 
chmod +x install_Time_Capsule_Proxy.sh && 
./install_Time_Capsule_Proxy.sh
