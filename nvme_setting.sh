#!/bin/bash

#40-nvme.sh
set -euo pipefail

echo "nvme setting"

DISK="/dev/nvme0n1"
PARTITION="${DISK}p1"
MOUNT_POINT="/mnt/nvme"

if [ ! -b "$DISK" ]; then
    echo "$DISK does not exist."
    exit 1
fi

if findmnt -rn -S "$DISK" >/dev/null 2>&1; then
    echo "$DISK is mounted. Refusing to modify it."
    exit 1
fi

mapfile -t PARTITIONS < <(lsblk -nrpo NAME,TYPE "$DISK" | awk '$2 == "part" {print $1}')

if [ "${#PARTITIONS[@]}" -gt 1 ] || { [ "${#PARTITIONS[@]}" -eq 1 ] && [ "${PARTITIONS[0]}" != "$PARTITION" ]; }; then
    echo "Existing partitions were found on $DISK. Refusing to repartition it."
    printf '  %s\n' "${PARTITIONS[@]}"
    exit 1
fi

if [ "${#PARTITIONS[@]}" -eq 0 ]; then
    if sudo wipefs -n "$DISK" | grep -q .; then
        echo "Existing filesystem or partition signatures were found on $DISK."
        echo "Refusing to erase the disk."
        exit 1
    fi

    echo "WARNING: $DISK is empty and will be partitioned and formatted as ext4."
    read -r -p "Type INITIALIZE to continue: " CONFIRM
    if [ "$CONFIRM" != "INITIALIZE" ]; then
        echo "NVMe initialization canceled."
        exit 1
    fi

    sudo parted "$DISK" --script mklabel gpt
    sudo parted "$DISK" --script mkpart primary 0% 100%
    sudo partprobe "$DISK"
    sudo udevadm settle
    for _ in {1..10}; do
        [ -b "$PARTITION" ] && break
        sleep 1
    done
    if [ ! -b "$PARTITION" ]; then
        echo "The new partition $PARTITION was not detected."
        exit 1
    fi
    sudo mkfs.ext4 "$PARTITION"
else
    echo "Using existing partition $PARTITION without formatting."
fi

if findmnt -rn -S "$PARTITION" >/dev/null 2>&1; then
    echo "$PARTITION is already mounted."
else
    echo "$PARTITION is not mounted yet."
fi

# Get the UUID of the nvme0n1p1 partition
NVME_UUID=$(sudo blkid -s UUID -o value "$PARTITION")
if [ -z "$NVME_UUID" ]; then
    echo "Failed to retrieve UUID for $PARTITION."
    exit 1
else
    echo "UUID for /dev/nvme0n1p1: $NVME_UUID"
fi

# Create the mount point if it doesn't exist
if [ ! -d "$MOUNT_POINT" ]; then
    echo "Creating mount point $MOUNT_POINT..."
    sudo mkdir -p "$MOUNT_POINT"
fi

# Update only this script's mount point entry; preserve unrelated fstab entries.
FSTAB_BACKUP="/etc/fstab.tdlas-backup.$(date +%Y%m%d%H%M%S)"
sudo cp -p /etc/fstab "$FSTAB_BACKUP"
if grep -qE "[[:space:]]${MOUNT_POINT//\//\\/}[[:space:]]" /etc/fstab; then
    echo "Updating the $MOUNT_POINT entry in /etc/fstab..."
    sudo sed -i "\|[[:space:]]${MOUNT_POINT//\//\\/}[[:space:]]|c\\UUID=$NVME_UUID $MOUNT_POINT ext4 defaults 0 0" /etc/fstab
else
    echo "Adding UUID to /etc/fstab..."
    echo "UUID=$NVME_UUID $MOUNT_POINT ext4 defaults 0 0" | sudo tee -a /etc/fstab >/dev/null
fi

# Mount the partition
echo "Mounting $MOUNT_POINT..."
sudo mount -a

if ! findmnt -rn -M "$MOUNT_POINT" >/dev/null; then
    echo "Failed to mount $MOUNT_POINT. Restore /etc/fstab from $FSTAB_BACKUP if needed."
    exit 1
fi

lsblk