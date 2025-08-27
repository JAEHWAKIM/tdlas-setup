#!/bin/bash

if [ -f "netplan.sh.cpt" ]; then
    echo "Decrypting netplan.sh.cpt..."
    echo "Enter password..."
    ccrypt -d -c -K test1234 netplan.sh.cpt >> netplan.sh
fi

if [ -f "netplan.sh" ]; then
    mv -v netplan.sh ./temp/
    chmod +x "./temp/netplan.sh"
    sudo cp -v "./temp/netplan.sh" /opt/tdlas/
fi