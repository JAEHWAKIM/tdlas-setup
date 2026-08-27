#!/bin/bash
set -euo pipefail

sudo ufw allow ssh
sudo ufw allow 6313
sudo ufw allow 6314
sudo ufw allow 3306
sudo ufw --force enable

sudo ufw status