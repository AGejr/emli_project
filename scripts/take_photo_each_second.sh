#!/bin/bash

while true; do
    
    trigger="Time"

    ./take_photo.sh "$trigger"

    folder_name=$(date +"%Y-%m-%d")
    latest_photos=($(ls -t ./$folder_name/*.jpg | head -n 2))

    if [ ${#latest_photos[@]} -gt 1 ]; then

        motion_result=$(python3 detect_motion.py "${latest_photos[1]}" "${latest_photos[0]}")

        if [ "$motion_result" == "motion" ]; then

            trigger="motion"
        fi
    fi

    sleep 1
done