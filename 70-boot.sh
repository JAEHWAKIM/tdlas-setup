#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config_helpers.sh"

#40-nvme.sh
echo "boot config"

# Enable NVMe support in /boot/firmware/config.txt
CONFIG_FILE="/boot/firmware/config.txt"

if ! grep -qxF "dtparam=nvme" "$CONFIG_FILE"; then
    echo "dtparam=nvme" | sudo tee -a "$CONFIG_FILE" >/dev/null
fi
if ! grep -qxF "dtparam=pciex1_gen=3" "$CONFIG_FILE"; then
    echo "dtparam=pciex1_gen=3" | sudo tee -a "$CONFIG_FILE" >/dev/null
fi
set_config_value "$CONFIG_FILE" max_usb_current_enable 1
set_config_value "$CONFIG_FILE" hdmi_force_hotplug 1
set_config_value "$CONFIG_FILE" hdmi_cvt "1024 600 60 3 0 0 0"
set_config_value "$CONFIG_FILE" hdmi_group 2
set_config_value "$CONFIG_FILE" hdmi_mode 87

# Prompt for restart
read -p "System needs to restart for changes to take effect. Restart now? (y/n): " RESTART_CONFIRM
if [[ "$RESTART_CONFIRM" == "y" || "$RESTART_CONFIRM" == "Y" ]]; then
    echo "Restarting system..."
    sudo reboot
else
    echo "Restart canceled. Please restart manually to apply changes."
fi
