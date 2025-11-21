#!/bin/bash

if [ "${TDLAS_SETUP}" = "true" ]; then
    new_hostname="${TDLAS_HOSTNAME}"
else
    read -p "Enter the new hostname: " new_hostname
fi

sudo hostnamectl set-hostname "$new_hostname"
echo "Hostname changed to $new_hostname"