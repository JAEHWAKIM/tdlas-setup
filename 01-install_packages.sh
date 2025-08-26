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
)

for package in "${packages[@]}"; do
    if ! dpkg -l | grep -q "^ii  $package "; then
        echo "Installing $package..."
        sudo apt install -y "$package"
    else
        echo "$package is already installed."
    fi
done
