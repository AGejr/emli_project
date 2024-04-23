#!/bin/bash

function sync_images {
  echo "Syncing images..."
  rsync -avz --progress emli@10.0.0.10:/home/emli/Images ./
  echo "Images synced"
  nmcli connection down EMLI-TEAM-16
  exit 0
}

while [[ true ]]; do 
  nmcli device wifi rescan
  # If wifi with SSID EMLI-TEAM-16 is found 
  if [[ $(nmcli -t -f ssid dev wifi | grep '^EMLI-TEAM-16$' | wc -l) == 1 ]]; then  
    echo "EMLI-TEAM-16 wifi visible"
    # If already connected to the network then sync images
    if [[ $(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d ':' -f2) == 'EMLI-TEAM-16' ]]; then
      sync_images
    else
      # Connect to network and sync images
      nmcli device wifi connect EMLI-TEAM-16
      if [[ $? -eq 0 ]]; then
        echo "Connected to wifi"
        sync_images
      else
        echo "Could not connect to wifi"
      fi
    fi
  fi
  sleep 1
done
