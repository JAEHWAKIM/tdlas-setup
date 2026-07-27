#!/bin/bash

#40-nvme.sh
echo "nvme setting"
if ! lsblk | grep -q "nvme0n1"; then
    echo "nvme0n1 does not exist."
    exit 1
fi

# Create a partition on nvme0n1
if ! lsblk | grep -q "nvme0n1p1"; then
    echo "Creating partition on nvme0n1 using parted..."
    sudo parted /dev/nvme0n1 --script mklabel gpt && \
    sudo parted /dev/nvme0n1 --script mkpart primary 0% 100%
    if [ $? -eq 0 ]; then
        echo "Partition created successfully."

        sudo mkfs.ext4 -F /dev/nvme0n1p1
    else
        echo "Failed to create partition."
        exit 1
    fi
else
    echo "Partition nvme0n1p1 already exists."
fi


# Get the UUID of the nvme0n1p1 partition
NVME_UUID=$(sudo blkid | grep "/dev/nvme0n1p1" | awk -F '"' '{print $2}')
if [ -z "$NVME_UUID" ]; then
    echo "Failed to retrieve UUID for /dev/nvme0n1p1."
    exit 1
else
    echo "UUID for /dev/nvme0n1p1: $NVME_UUID"
fi

# Check if the UUID exists in /etc/fstab
if grep -q "UUID=" /etc/fstab; then
    echo "UUID already exists in /etc/fstab. Updating entry..."
    sudo sed -i "s|^UUID=.*|UUID=$NVME_UUID /mnt/nvme ext4 defaults 0 0|" /etc/fstab
else
    echo "Adding UUID to /etc/fstab..."
    echo "UUID=$NVME_UUID /mnt/nvme ext4 defaults 0 0" | sudo tee -a /etc/fstab
fi

# Create the mount point if it doesn't exist
if [ ! -d "/mnt/nvme" ]; then
    echo "Creating mount point /mnt/nvme..."
    sudo mkdir -p /mnt/nvme
fi

# Mount the partition
echo "Mounting /mnt/nvme..."
sudo mount -a

lsblk