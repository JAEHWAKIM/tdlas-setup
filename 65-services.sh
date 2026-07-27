#!/bin/bash

# Enable NVMe support in /boot/firmware/config.txt

TARGET_PATH="/etc/systemd/system/"

sudo cp tdlas.service tdlasbr.service tdlasinfo.service "$TARGET_PATH"

cp run_dashboard /opt/tdlas/

sudo cp dsi-backlight.service "$TARGET_PATH"
sudo cp enable-backlight.sh /usr/local/bin/

#sudo systemctl mask getty@tty1
sudo systemctl enable dsi-backlight.service
sudo systemctl enable tdlasbr
sudo systemctl enable tdlas
sudo systemctl enable tdlasinfo


