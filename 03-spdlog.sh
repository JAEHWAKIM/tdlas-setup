#!/bin/bash

SOURCE_URL="https://github.com/gabime/spdlog.git"
TARGET_DIR="$HOME/sources/spdlog"

if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
    git clone "$SOURCE_URL" "$TARGET_DIR"
fi

cd "$TARGET_DIR"
mkdir build
cd build
cmake ..
sudo make install

LOG_PATH="/var/log/tdlas"
PROGRAM_USER="easyrnd"
PROGRAM_GROUP="easyrnd"

if [ ! -d "$LOG_PATH" ]; then
    sudo mkdir -p -v "$LOG_PATH"
    sudo chmod 770 "$LOG_PATH"
    sudo chown "$PROGRAM_USER":"$PROGRAM_GROUP" "$LOG_PATH"
fi

LOGROTATE_CONF="/etc/logrotate.d/tdlas"
sudo bash -c "cat > $LOGROTATE_CONF" <<EOL
$LOG_PATH/*.log {
    monthly
    size 100M
    rotate 20
    compress
    delaycompress
    missingok
    notifempty
    create 0660 $PROGRAM_USER $PROGRAM_GROUP
}
EOL