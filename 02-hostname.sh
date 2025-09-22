#!/bin/bash

read -p "Enter the new hostname: " new_hostname
sudo hostnamectl set-hostname "$new_hostname"
echo "Hostname changed to $new_hostname"