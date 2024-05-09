#!/bin/bash

log_usage() {
    local log_dir="/home/emli/Git/emli_project/cam" 
    local log_file="${log_dir}/take_photo.log"
    
    if [ ! -d "$log_dir" ]; then
        mkdir -p "$log_dir"
    fi

    if [ ! -f "$log_file" ]; then
        touch "$log_file"
    fi

    local timestamp=$(date +"%Y-%m-%d %H:%M:%S.%3N%:z")
    echo "$timestamp take_photo.sh $1" >> "$log_file"
}


create_metadata ()
{
  echo "Extracting EXIF from $3/$2"
  subject_distance=$(exiftool -SubjectDistance $3/$2 | awk -F': ' '{print $2}')
  exposure_time=$(exiftool -ExposureTime $3/$2 | awk -F': ' '{print $2}')
  iso=$(exiftool -ISO $3/$2 | awk -F': ' '{print $2}')
  metadata="
  {
    \"File Name\": \"$2\",
    \"Create Date\": \"$(date +"%Y-%m-%d %H:%M:%S.%3N%:z")\",
    \"Create Seconds Epoch\": $(date +"%s.%3N"),
    \"Trigger\": \"$1\",
    \"Subject Distance\": \"$subject_distance\",
    \"Exposure Time\": \"$exposure_time\",
    \"ISO\": $iso
  }
  "
  echo "Create metadata"
  metadata_filename=$(echo $2 | sed 's/jpg/json/')
  echo $metadata | tee $3/$metadata_filename
  echo "Saved metadata to $3/$metadata_filename"
}

trigger=$1

log_usage $trigger

# Determine folder based on trigger
if [[ "$trigger" == "motion" ]]; then
  folder_name="/tmp/images"
else
  folder_name="/home/emli/Git/emli_project/images/$(date +"%Y-%m-%d")"
fi

# Ensure the folder exists
if [[ ! -d $folder_name ]]; then
  echo "Making directory $folder_name"
  mkdir -p $folder_name
fi

file_name=$(date +"%H%M%S_%3N.jpg")
file_path="$folder_name/$file_name"

rpicam-still -t 0.01 -o $file_path
echo "Saving pic as $file_path"

create_metadata $trigger $file_name $folder_name
