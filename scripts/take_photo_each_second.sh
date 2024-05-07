#!/bin/bash

BASE_DIR=$(pwd)

take_photo() {
    local output=$(./take_photo.sh motion 2>&1)
    echo "$output"
    local dir_line=$(echo "$output" | grep 'Making dir')
    if [[ $dir_line =~ Making\ dir\ (.*) ]]; then
        photo_directory="${BASE_DIR}/${BASH_REMATCH[1]}"  # Use full path for clarity
        echo "Using directory: $photo_directory"
    fi
}

detect_motion() {
    local imgs=($(ls $photo_directory/*.jpg -t))
    if [ ${#imgs[@]} -lt 2 ]; then
        echo "Not enough images to compare."
        return
    fi

    local img1="${imgs[0]}"
    local img2="${imgs[1]}"

    echo "Image 1: $img1"
    echo "Image 2: $img2"

    local motion_result=$(python3 ../motion_detect/motion_detect.py "$photo_directory/$img1" "$photo_directory/$img2")
    echo "$motion_result"
}

while true; do
    take_photo
    sleep 1
    if [ $(ls $photo_directory/*.jpg | wc -l) -ge 2 ]; then
        local motion_output=$(detect_motion)
        echo "$motion_output"
        if [[ "$motion_output" == *"Motion detected"* ]]; then
            echo "Motion detected - keeping images."
            # In this case, keep both images and do nothing else
        else
            # If no motion detected, delete the oldest image
            oldest=$(ls $photo_directory/*.jpg -t | tail -n 1)
            echo "Removing oldest image: $oldest"
            rm -- "$photo_directory/$oldest"
            # Remove the corresponding JSON file
            local oldest_json="${oldest%.jpg}.json"
            if [ -f "$photo_directory/$oldest_json" ]; then
                rm -- "$photo_directory/$oldest_json"
                echo "Removed metadata file: $oldest_json"
            fi
            echo "No motion detected - removed the oldest image and its metadata."
        fi
    fi
done
