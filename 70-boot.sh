#!/bin/bash


#40-nvme.sh
echo "boot config"

# Enable NVMe support in /boot/firmware/config.txt
CONFIG_FILE="/boot/firmware/config.txt"

# Add dtparam=nvme and dtparam=pciex1_gen=3 to the last lines of the config file
if ! grep -q "^dtparam=nvme" "$CONFIG_FILE"; then
    echo "Adding dtparam=nvme to $CONFIG_FILE..."
    echo "dtparam=nvme" | sudo tee -a "$CONFIG_FILE"
else
    echo "dtparam=nvme already exists in $CONFIG_FILE."
fi

if ! grep -q "^dtparam=pciex1_gen=3" "$CONFIG_FILE"; then
    echo "Adding dtparam=pciex1_gen=3 to $CONFIG_FILE..."
    echo "dtparam=pciex1_gen=3" | sudo tee -a "$CONFIG_FILE"
else
    echo "dtparam=pciex1_gen=3 already exists in $CONFIG_FILE."
fi

# Enable max USB current in /boot/firmware/config.txt
if ! grep -q "^max_usb_current_enable=1" "$CONFIG_FILE"; then
    echo "Adding max_usb_current_enable=1 to $CONFIG_FILE..."
    echo "max_usb_current_enable=1" | sudo tee -a "$CONFIG_FILE"
else
    echo "max_usb_current_enable=1 already exists in $CONFIG_FILE."
fi

if ! grep -q "^hdmi_force_hotplug=1" "$CONFIG_FILE"; then
    echo "Adding hdmi_force_hotplug=1 to $CONFIG_FILE..."
    echo "hdmi_force_hotplug=1" | sudo tee -a "$CONFIG_FILE"
else
    echo "hdmi_force_hotplug=1 already exists in $CONFIG_FILE."
fi

if ! grep -q "^hdmi_cvt=1024 600 60 3 0 0 0" "$CONFIG_FILE"; then
    echo "Adding hdmi_cvt=1024 600 60 3 0 0 0 to $CONFIG_FILE..."
    echo "hdmi_cvt=1024 600 60 3 0 0 0" | sudo tee -a "$CONFIG_FILE"
else
    echo "hdmi_cvt=1024 600 60 3 0 0 0 already exists in $CONFIG_FILE."
fi

if ! grep -q "^hdmi_group=2" "$CONFIG_FILE"; then
    echo "Adding hdmi_group=2 to $CONFIG_FILE..."
    echo "hdmi_group=2" | sudo tee -a "$CONFIG_FILE"
else
    echo "hdmi_group=2 already exists in $CONFIG_FILE."
fi

if ! grep -q "^hdmi_mode=87" "$CONFIG_FILE"; then
    echo "Adding hdmi_mode=87 to $CONFIG_FILE..."
    echo "hdmi_mode=87" | sudo tee -a "$CONFIG_FILE"
else
    echo "hdmi_mode=87 already exists in $CONFIG_FILE."
fi

# Prompt for restart
read -p "System needs to restart for changes to take effect. Restart now? (y/n): " RESTART_CONFIRM
if [[ "$RESTART_CONFIRM" == "y" || "$RESTART_CONFIRM" == "Y" ]]; then
    echo "Restarting system..."
    sudo reboot
else
    echo "Restart canceled. Please restart manually to apply changes."
fi

