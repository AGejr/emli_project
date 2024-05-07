#!/bin/bash

BASE_DIR=$(pwd)

take_photo() {
    local output=$(./take_photo.sh motion 2>&1)
    echo "$output"
    local dir_line=$(echo "$output" | grep 'Making dir')
    if [[ $dir_line =~ Making\ dir\ (.*) ]]; then
        photo_directory="./${BASH_REMATCH[1]}"  # Use './' to indicate the current directory
        echo "Using directory: $photo_directory"
    fi
}

detect_motion() {
    local img1=$(ls $photo_directory -t | head -n 1)
    echo "Image 1: $img1"
    local img2=$(ls $photo_directory -t | head -n 2 | tail -n 1)
    echo "Image 2: $img2"
    motion_result=$(python3 ../motion_detect/motion_detect.py "$photo_directory/$img1" "$photo_directory/$img2")
    echo "$motion_result"
    }

while true; do
    take_photo
    sleep 1
    if [ $(ls $photo_directory | wc -l) -ge 2 ]; then
        motion_output=$(detect_motion)
        echo "$motion_output"
        if [[ "$motion_output" == *"Motion detected"* ]]; then
            echo "Motion detected - keeping images."
            # Keep both images; no delete logic here for the motion detected case
        else
            # If no motion detected, delete the older image
            oldest=$(ls $photo_directory -t | tail -n 1)
            rm -- "$photo_directory/$oldest"
            rm -- "${photo_directory}/${oldest%.jpg}.json"
            echo "No motion detected - removed the oldest image."
        fi
    fi
done