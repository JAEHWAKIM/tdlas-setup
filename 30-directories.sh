#!/bin/bash

#30-directories.sh
dirs=(
    /mnt/nvme
    /media/usb
    /opt/tdlas
    /etc/opt/tdlas
    /etc/opt/tdlas/recipe
)

for dir in "${dirs[@]}"; do
    if [ ! -d "$dir" ]; then
        sudo mkdir -p -v "$dir"
    fi
done
