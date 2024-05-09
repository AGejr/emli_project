#!/bin/bash

BASE_DIR=$(pwd)

take_photo() {
    local output=$(./home/emli/Git/emli_project/cam/scripts/take_photo.sh motion 2>&1)
    echo "$output"
    local dir_line=$(echo "$output" | grep 'Making dir')
    if [[ $dir_line =~ Making\ dir\ (.*) ]]; then
        photo_directory="/home/emli/Git/emil_project/cam/temp"
        echo "Using directory: $photo_directory"
    fi
}

detect_motion() {
    local imgs=($(ls $photo_directory/*.jpg -t))
    if [ ${#imgs[@]} -lt 2 ]; then
        echo "Not enough images to compare."
        return
    fi

    local img1="${imgs[0]}"  # This should give the full path
    local img2="${imgs[1]}"  # This should give the full path

    echo "Calling Python script with:"
    echo "Image 1: $img1"
    echo "Image 2: $img2"

    local motion_result=$(python3 /home/emli/Git/emli_project/cam/motion_detect/motion_detect.py "$img1" "$img2")
    echo "$motion_result"
}

while true; do
    take_photo
    sleep 1
    if [ $(ls $photo_directory/*.jpg | wc -l) -ge 2 ]; then
        newest=$(ls -t $photo_directory/*.jpg | head -n 1)
        newest_json="${newest%.jpg}.json"

        oldest=$(ls $photo_directory/*.jpg -t | tail -n 1)
        oldest_json="${oldest%.jpg}.json"

        motion_output=$(detect_motion)
        echo "$motion_output"
        if [[ "$motion_output" == *"Motion detected"* ]]; then
	    
        echo "Motion detected - keeping image"
            
	    cp "$newest" "/home/emli/Git/emli_project/images"
	    cp "$newest_json" "/home/emli/Git/emli_project/images"

        echo "Images and json had been coopied"    

        echo "Removing oldest image: $oldest"
            rm -- "$oldest"
            # Remove the corresponding JSON file
            if [ -f "$oldest_json" ]; then
                rm -- "$oldest_json"
                echo "Removed metadata file: $oldest_json"
            fi
            
	    # In this case, keep both images and do nothing else
        else
            # If no motion detected, delete the oldest image
            echo "Removing oldest image: $oldest"
            rm -- "$oldest"
            # Remove the corresponding JSON file
            if [ -f "$oldest_json" ]; then
                rm -- "$oldest_json"
                echo "Removed metadata file: $oldest_json"
            fi
            echo "No motion detected - removed the oldest image and its metadata."
        fi
    fi
done
???END
