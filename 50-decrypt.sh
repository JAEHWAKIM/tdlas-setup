#!/bin/bash

cd "$(dirname "$0")"

if [ -f "51-sources.sh.cpt" ]; then
    echo "Decrypting 51-sources.sh.cpt..."
    echo "Enter password..."
    ccrypt -d -c 51-sources.sh.cpt >> 51-sources.sh
fi

if [ -f "51-sources.sh" ]; then
    mv -v 51-sources.sh ./temp/
    chmod +x "./temp/51-sources.sh"
    ./temp/51-sources.sh

    cd ~/sources/das
    mkdir build
    cd build
    cmake -S .. -B . -D CMAKE_BUILD_TYPE=Release
    make
    sudo make install
    sudo ln -s /opt/tdlas/das /bin/das
    sudo ln -s /opt/tdlas/broadcast_receiver /bin/broadcast_receiver

    cd ~/sources/cfwms
    mkdir build
    cd build
    cmake -S .. -B . -D CMAKE_BUILD_TYPE=Release
    make
    sudo make install
    sudo ln -s /opt/tdlas/cfwms /bin/cfwms

    cd ~/sources/tdlas
    mkdir build
    cd build
    cmake -S .. -B . -D CMAKE_BUILD_TYPE=Release
    make
    sudo make install
    sudo ln -s /opt/tdlas/tdlas /bin/tdlas
    sudo ln -s /opt/tdlas/dashboard /bin/tdlasinfo
    sudo ln -s /opt/tdlas/broadcast_receiver /bin/tdlasbr
fi