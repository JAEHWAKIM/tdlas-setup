#!/bin/bash

echo 0 > /sys/class/backlight/*/bl_power
echo 31 > /sys/class/backlight/*/brightness

echo 1 > /sys/class/graphics/fbcon/rotate_all