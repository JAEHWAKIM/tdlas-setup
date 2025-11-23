#!/bin/bash

if [ "${TDLAS_SETUP}" = "true" ]; then
    angle="${TDLAS_DISPLAY_ROTATE}"
else
    read -p "Enter the rotation angle (0, 90, 180, 270): " angle
fi

case "$angle" in
    0)
        rotation=0
        ;;
    90)
        rotation=1
        ;;
    180)
        rotation=2
        ;;
    270)
        rotation=3
        ;;
    *)
        echo "Invalid angle. Please choose from 0, 90, 180, or 270."
        exit 1
        ;;
esac

echo $rotation > /sys/class/graphics/fbcon/rotate_all

echo "Screen rotation set to $angle degrees."