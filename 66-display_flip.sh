#!/bin/bash

read -p "Do you want to flip the screen? (yes|no): " answer
if [[ "$answer" != "yes" && "$answer" != "y" ]]; then
    echo "Screen flip operation canceled."
    exit 0
fi

if ! sudo crontab -l 2>/dev/null | grep -q "@reboot /bin/bash -c \"echo 2 > /sys/class/graphics/fbcon/rotate_all\""; then
    (sudo crontab -l 2>/dev/null; echo "@reboot /bin/bash -c \"echo 2 > /sys/class/graphics/fbcon/rotate_all\"") | sudo crontab -
fi