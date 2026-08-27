#!/bin/bash
set -euo pipefail

AUTOREMOVER_PATH="/opt/tdlas/auto_remover.sh"

sudo tee "$AUTOREMOVER_PATH" > /dev/null <<'EOF'
#!/bin/bash
set -euo pipefail

TARGET_PATH="/mnt/nvme"
MAX_USAGE=80
MIN_AGE_DAYS=365

# Never delete from the underlying root filesystem if the NVMe is not mounted.
SOURCE=$(findmnt -rn -M "$TARGET_PATH" -o SOURCE || true)
if [[ -z "$SOURCE" || "$SOURCE" != /dev/nvme* ]]; then
    echo "Auto-removal skipped: $TARGET_PATH is not mounted from an NVMe device."
    exit 0
fi

USAGE_INT=$(df -P -- "$TARGET_PATH" | awk 'NR == 2 {gsub(/%/, "", $5); print $5}')
if [[ ! "$USAGE_INT" =~ ^[0-9]+$ ]]; then
    echo "Auto-removal skipped: unable to determine disk usage."
    exit 1
fi

if (( USAGE_INT <= MAX_USAGE )); then
    echo "$TARGET_PATH=$USAGE_INT%"
    exit 0
fi

echo "$TARGET_PATH usage is $USAGE_INT%; looking for directories older than $MIN_AGE_DAYS days."
mapfile -d '' CANDIDATES < <(
    find "$TARGET_PATH" -mindepth 3 -maxdepth 3 -type d -mtime +"$MIN_AGE_DAYS" -print0 | sort -z
)

if (( ${#CANDIDATES[@]} == 0 )); then
    echo "No eligible directories found."
    exit 0
fi

DIR="${CANDIDATES[0]}"
echo "[$DIR] REMOVING BEGIN ================"
rm -rfv -- "$DIR"
echo "[$DIR] REMOVING END ================"

find "$TARGET_PATH" -mindepth 1 -type d -empty -delete -print
EOF

sudo chmod 755 "$AUTOREMOVER_PATH"
sudo chown root:root "$AUTOREMOVER_PATH"

if ! sudo crontab -l 2>/dev/null | grep -Fq "$AUTOREMOVER_PATH"; then
    (sudo crontab -l 2>/dev/null; echo "*/10 * * * * $AUTOREMOVER_PATH") | sudo crontab -
fi
