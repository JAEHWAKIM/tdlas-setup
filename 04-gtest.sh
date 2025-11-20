#!/bin/bash

SOURCE_URL="https://github.com/google/googletest.git"
TARGET_DIR="$HOME/sources/googletest"

if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
    git clone "$SOURCE_URL" "$TARGET_DIR"
fi

cd "$TARGET_DIR"
mkdir build
cd build
cmake ..
sudo make install