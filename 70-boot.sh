#!/bin/bash


#40-nvme.sh
echo "boot config"

# Enable NVMe support in /boot/firmware/config.txt
CONFIG_FILE="/boot/firmware/config.txt"

# Append config line only when the exact key=value line does not exist.
ensure_config_line() {
    local config_file="$1"
    local key="$2"
    local value="$3"
    local line="${key}=${value}"

    if ! grep -q "^${line}$" "$config_file"; then
        echo "Adding ${line} to $config_file..."
        echo "$line" | sudo tee -a "$config_file"
    else
        echo "${line} already exists in $config_file."
    fi
}

ensure_config_line "$CONFIG_FILE" "dtparam" "nvme"
ensure_config_line "$CONFIG_FILE" "dtparam" "pciex1_gen=3"
ensure_config_line "$CONFIG_FILE" "max_usb_current_enable" "1"
ensure_config_line "$CONFIG_FILE" "dtoverlay" "vc4-kms-v3d"
ensure_config_line "$CONFIG_FILE" "dtoverlay" "vc4-kms-dsi-ili9881-5inch"
ensure_config_line "$CONFIG_FILE" "dtparam" "backlight=on"

#구버전
#ensure_config_line "$CONFIG_FILE" "hdmi_force_hotplug" "1"
#ensure_config_line "$CONFIG_FILE" "hdmi_cvt" "1024 600 60 3 0 0 0"
#ensure_config_line "$CONFIG_FILE" "hdmi_group" "2"
#ensure_config_line "$CONFIG_FILE" "hdmi_mode" "87"

# Prompt for restart
read -p "System needs to restart for changes to take effect. Restart now? (y/n): " RESTART_CONFIRM
if [[ "$RESTART_CONFIRM" == "y" || "$RESTART_CONFIRM" == "Y" ]]; then
    echo "Restarting system..."
    sudo reboot
else
    echo "Restart canceled. Please restart manually to apply changes."
fi

