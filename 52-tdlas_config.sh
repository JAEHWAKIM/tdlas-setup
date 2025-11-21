#!/bin/bash

TDLAS_CONFIG_PATH="/etc/opt/tdlas/tdlas.config"

if [ ! -d "$(dirname "$TDLAS_CONFIG_PATH")" ]; then
    sudo mkdir -p "$(dirname "$TDLAS_CONFIG_PATH")"
fi

if [ "${TDLAS_SETUP}" = "true" ]; then
    DEVICE_NAME="${TDLAS_DEVICE_NAME}"
    SERIAL_NUMBER="${TDLAS_DEVICE_SERIAL_NUMBER}"
else
    read -p "Enter device name: " DEVICE_NAME
    read -p "Enter serial number: " SERIAL_NUMBER
fi

sudo tee "$TDLAS_CONFIG_PATH" > /dev/null <<EOF
[TDLAS]
DEVICE_NAME=$DEVICE_NAME
SERIAL_NUMBER=$SERIAL_NUMBER

[LOG]
PROGRAM_LEVEL=0
DB_LEVEL=2
USB_LEVEL=2
SERVER_LEVEL=2
EOF