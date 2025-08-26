#!/bin/bash

AUTOREMOVER_PATH="/opt/tdlas/auto_remover.sh"

if [ -f "$AUTOREMOVER_PATH" ]; then
    echo "$AUTOREMOVER_PATH does exist."
    exit 0
fi

sudo tee "$AUTOREMOVER_PATH" > /dev/null <<EOF
#!/bin/bash
TARGET_PATH=/mnt/nvme/
DISK_USAGE=\`df \${TARGET_PATH} | grep -v Use | awk '{print \$5}'\`

#echo \$DISK_USAGE #0%

USAGE_STR=\`echo \${DISK_USAGE} | cut -d '%' -f 1\`
USAGE_INT=\`expr \$USAGE_STR\`

MAX_USAGE=80

RED='\033[0;31m'
NC='\033[0m'


if [ \${USAGE_INT} -gt \${MAX_USAGE} ]; then

        echo -e \${TARGET_PATH}=\${RED}\$USAGE_INT%\${NC}
        echo -e "Disk space is at least" \${RED}\${MAX_USAGE}%\${NC}

        RDIRS=\`find \${TARGET_PATH} -mindepth 3 -maxdepth 3 -type d | sort\`

        for dir in \${RDIRS}
        do
                echo "[\$dir] REMOVING BEGIN ================"

                rm -rfv \$dir

                echo "[\$dir] REMOVING END ================"

                break;
        done

        find \${TARGET_PATH} -empty -type d -delete -print

else
        echo \${TARGET_PATH}=\$USAGE_INT%
fi

EOF

sudo chmod +x "$AUTOREMOVER_PATH"
sudo chown root:root "$AUTOREMOVER_PATH"

if ! sudo crontab -l 2>/dev/null | grep -q "$AUTOREMOVER_PATH"; then
    (sudo crontab -l 2>/dev/null; echo "*/10 * * * * $AUTOREMOVER_PATH") | sudo crontab -
fi
