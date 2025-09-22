#!/bin/bash

TDLAS_CONFIG_PATH="/etc/opt/tdlas/tdlas.config"

if [ ! -d "$(dirname "$TDLAS_CONFIG_PATH")" ]; then
    sudo mkdir -p "$(dirname "$TDLAS_CONFIG_PATH")"
fi

read -p "Enter device name: " DEVICE_NAME
read -p "Enter serial number: " SERIAL_NUMBER

sudo tee "$TDLAS_CONFIG_PATH" > /dev/null <<EOF
[TDLAS]
DEVICE_NAME=$DEVICE_NAME
SERIAL_NUMBER=$SERIAL_NUMBER
EOF