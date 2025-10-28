#!/bin/bash

#30-directories.sh
PROGRAM_USER="easyrnd"
PROGRAM_GROUP="easyrnd"

dirs=(
    /mnt/nvme
    /media/usb
    /opt/tdlas
    /etc/opt/tdlas
    /etc/opt/tdlas/das
    /etc/opt/tdlas/das/recipe
    /etc/opt/tdlas/cfwms
    /etc/opt/tdlas/cfwms/recipe
)

for dir in "${dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        sudo mkdir -p -v "$dir"
    fi
    sudo chmod 770 "$dir"
    sudo chown "$PROGRAM_USER":"$PROGRAM_GROUP" "$dir"
done
