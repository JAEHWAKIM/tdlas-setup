#!/bin/bash
set -euo pipefail

TYPE="${TDLAS_TYPE:-}"

TARGET_PATH="/etc/systemd/system/"

sudo cp tdlas.service tdlasbr.service tdlasinfo.service das.service cfwms.service "$TARGET_PATH"

cp run_dashboard /opt/tdlas/

sudo systemctl mask getty@tty1
sudo systemctl daemon-reload

case "$TYPE" in
    tdlas|TDLAS)
        sudo systemctl enable tdlasbr tdlas tdlasinfo
        ;;
    das|DAS)
        sudo systemctl enable tdlasbr das
        ;;
    wms|WMS)
        sudo systemctl enable tdlasbr cfwms
        ;;
    *)
        echo "Unsupported installation type: $TYPE"
        exit 1
        ;;
esac

