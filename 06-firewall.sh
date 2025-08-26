#!/bin/bash

sudo ufw enable

sudo ufw allow ssh
sudo ufw allow 6313
sudo ufw allow 6314
sudo ufw allow 3306

sudo ufw status