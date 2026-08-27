#!/bin/bash
set -euo pipefail

#20-driver.sh
cd "$(dirname "$0")"

DRIVER_VERSION="1.1.7"
DRIVER_FILENAME="libftd3xx-linux-arm-v8-${DRIVER_VERSION}.tgz"

if [ ! -d "./temp" ]; then
    mkdir ./temp
fi

cd ./temp

if [ -f "../${DRIVER_FILENAME}" ] && [ ! -f "${DRIVER_FILENAME}" ]; then
    cp "../${DRIVER_FILENAME}" .
fi

#압축해제
if [ ! -d "linux-arm-v8" ]; then
    if [ ! -f "$DRIVER_FILENAME" ]; then
        echo "Driver archive not found: $DRIVER_FILENAME"
        exit 1
    fi
    tar -xzf "$DRIVER_FILENAME"
fi

cd ./linux-arm-v8

#파일복사
sudo install -m 0644 "libftd3xx.so" "/usr/lib/libftd3xx.so"
sudo install -m 0644 "libftd3xx.so.${DRIVER_VERSION}" "/usr/lib/libftd3xx.so.${DRIVER_VERSION}"
sudo install -m 0644 "51-ftd3xx.rules" "/etc/udev/rules.d/51-ftd3xx.rules"
sudo udevadm control --reload-rules
