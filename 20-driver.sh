#!/bin/bash

#20-driver.sh
cd "$(dirname "$0")"

if [ ! -d "./temp" ]; then
    mkdir ./temp
fi

cd ./temp

#다운로드
if [ ! -f "libftd3xx-linux-arm-v8-1.0.16.tgz" ]; then
    wget https://ftdichip.com/wp-content/uploads/2024/07/libftd3xx-linux-arm-v8-1.0.16.tgz
fi

#압축해제
if [ ! -d "linux-arm-v8" ]; then
tar -xvzf libftd3xx-linux-arm-v8-1.0.16.tgz
fi

cd ./linux-arm-v8

#파일복사
if [ -f "/usr/lib/libftd3xx.so" ]; then
    sudo rm -v /usr/lib/libftd3xx.so
fi
sudo cp -v libftd3xx.so /usr/lib/
sudo cp -v libftd3xx.so.1.0.16 /usr/lib/
sudo cp -v 51-ftd3xx.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
