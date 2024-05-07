#!/bin/bash

function log_wifi_stats ()
{
  echo "Starting wifi logging"
  while [[ true ]]; do
    signal_level=$(cat /proc/net/wireless | grep $1 | tr -s ' ' | cut -d ' ' -f 4)
    link_quality=$(cat /proc/net/wireless | grep $1 | tr -s ' ' | cut -d ' ' -f 3)
    epoch_seconds=$(date +%s)
    echo "$epoch_seconds - Signal level: $signal_level, Link quality $link_quality" >> ./wifi_qual.log
    sleep 1
  done
}

function sync_images ()
{
  echo "Syncing images..."
  rsync -avz --progress emli@10.0.0.10:/home/emli/Images ./
  echo "Images synced"
}

function sync_local_to_remote ()
{
  echo "Syncing local to remote..."
  rsync -avz --progress ./Images/ emli@10.0.0.10:/home/emli/Images
  echo "Files synced"

}

function update_metadata () 
{
  drone_id="WILDDRONE-001"
  epoch_seconds=$(date +%s)
  metadata_files=$(find ./Images -type f -name '*.json')
  for metadata_file in $metadata_files
  do
    if jq '.["Drone Copy"]' "$metadata_file" | grep -q null; then
      jq --arg droneID "$drone_id" --argjson epoch "$epoch_seconds" \
        '.["Drone Copy"] = {"Drone ID": $droneID, "Seconds Epoch": $epoch}' \
        "$metadata_file" > temp.json && mv temp.json "$metadata_file"
      echo "Metadata updated for $metadata_file"
    else
      echo "Skipping $metadata_file"
    fi
  done
  sync_local_to_remote  
}

while [[ true ]]; do 
  nmcli device wifi rescan
  # If wifi with SSID EMLI-TEAM-16 is found 
  if [[ $(nmcli -t -f ssid dev wifi | grep '^EMLI-TEAM-16$' | wc -l) == 1 ]]; then  
    echo "EMLI-TEAM-16 wifi visible"
    # If already connected to the network then sync images
    if [[ $(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d ':' -f2) == 'EMLI-TEAM-16' ]]; then
      ./sync_time.sh
      log_wifi_stats wlp4s0 &
      log_wifi_stats_pid=$!
      sync_images
      update_metadata
      break 
    else
      # Connect to network and sync images
      nmcli device wifi connect EMLI-TEAM-16
      if [[ $? -eq 0 ]]; then
        echo "Connected to wifi"
        ./sync_time.sh
        log_wifi_stats wlp4s0 &
        log_wifi_stats_pid=$!
        sync_images
        update_metadata
        break
      else
        echo "Could not connect to wifi"
      fi
    fi
  fi
  sleep 1
done

nmcli connection down EMLI-TEAM-16
kill $log_wifi_stats_pid
trap "echo 'Stopping wifi logging'; kill $log_wifi_stats_pid" EXIT
exit 0
