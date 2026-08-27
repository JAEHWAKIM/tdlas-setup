#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

if [ -f "netplan.sh.cpt" ] && [ ! -f "./temp/netplan.sh" ]; then
    echo "Decrypting netplan.sh.cpt..."
    if [ "${TDLAS_SETUP:-}" = "true" ]; then
        ccrypt -d -c -K "${TDLAS_DECRYPTION_KEY}" netplan.sh.cpt > netplan.sh
    else
        echo "Enter password..."
        ccrypt -d -c netplan.sh.cpt > netplan.sh
    fi
fi

if [ -f "netplan.sh" ]; then
    mkdir -p ./temp
    mv -v netplan.sh ./temp/
    chmod 700 "./temp/netplan.sh"
    sudo cp -v "./temp/netplan.sh" /opt/tdlas/
fi