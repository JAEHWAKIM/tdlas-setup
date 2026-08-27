#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

if [ -f "51-sources.sh.cpt" ]; then
    echo "Decrypting 51-sources.sh.cpt..."

    if [ "${TDLAS_SETUP:-}" = "true" ]; then
        echo "Using predefined decryption key..."
        ccrypt -d -c -K "${TDLAS_DECRYPTION_KEY}" 51-sources.sh.cpt > 51-sources.sh
    else
        echo "Enter password..."
        ccrypt -d -c 51-sources.sh.cpt > 51-sources.sh
    fi
fi

if [ -f "51-sources.sh" ]; then
    mv -v 51-sources.sh ./temp/
    chmod +x "./temp/51-sources.sh"
    ./temp/51-sources.sh

    cd ~/sources/das
    mkdir -p build
    cd build
    cmake -S .. -B . -D CMAKE_BUILD_TYPE=Release
    make
    sudo make install
    sudo ln -sfn /opt/tdlas/das /bin/das
    sudo ln -sfn /opt/tdlas/broadcast_receiver /bin/broadcast_receiver

    if [[ "${TDLAS_TYPE:-}" = "wms" || "${TDLAS_TYPE:-}" = "WMS" ]]; then
        cd ~/sources/cfwms
        mkdir -p build
        cd build
        cmake -S .. -B . -D CMAKE_BUILD_TYPE=Release
        make
        sudo make install
        sudo ln -sfn /opt/tdlas/cfwms /bin/cfwms
    fi

    if [[ "${TDLAS_TYPE:-}" = "tdlas" || "${TDLAS_TYPE:-}" = "TDLAS" ]]; then
        cd ~/sources/tdlas
        mkdir -p build
        cd build
        cmake -S .. -B . -D CMAKE_BUILD_TYPE=Release
        make
        sudo make install
        sudo ln -sfn /opt/tdlas/tdlas /bin/tdlas
        sudo ln -sfn /opt/tdlas/dashboard /bin/tdlasinfo
        sudo ln -sfn /opt/tdlas/broadcast_receiver /bin/tdlasbr
    fi
fi