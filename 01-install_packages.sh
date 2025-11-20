#!/bin/bash

#01-install_packages.sh
# 패키지 설치 스크립트

sudo apt update

packages=(
    build-essential
    cmake
    git
    libeigen3-dev
    libboost-all-dev
    htop
    ccrypt
    libgpiod-dev
    gpiod
    libncurses-dev
)

for package in "${packages[@]}"; do
    if ! dpkg -l | grep -q "^ii  $package "; then
        echo "Installing $package..."
        sudo apt install -y "$package"
    else
        echo "$package is already installed."
    fi
done

# Set global Git configuration for user email and name
git config --global user.email "jh.kim@easyrnd.co.kr"
git config --global user.name "jh.kim"