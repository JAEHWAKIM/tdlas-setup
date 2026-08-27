#!/bin/bash
set -euo pipefail

SOURCE_URL="https://github.com/google/googletest.git"
TARGET_DIR="$HOME/sources/googletest"

if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
    git clone "$SOURCE_URL" "$TARGET_DIR"
fi

cd "$TARGET_DIR"
mkdir -p build
cd build
cmake ..
sudo make install