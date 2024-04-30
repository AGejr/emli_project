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

function sync_images {
  echo "Syncing images..."
  rsync -avz --progress emli@10.0.0.10:/home/emli/Images ./
  echo "Images synced"
  nmcli connection down EMLI-TEAM-16
  kill $log_wifi_stats_pid
  exit 0
}

while [[ true ]]; do 
  nmcli device wifi rescan
  # If wifi with SSID EMLI-TEAM-16 is found 
  if [[ $(nmcli -t -f ssid dev wifi | grep '^EMLI-TEAM-16$' | wc -l) == 1 ]]; then  
    echo "EMLI-TEAM-16 wifi visible"
    # If already connected to the network then sync images
    if [[ $(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d ':' -f2) == 'EMLI-TEAM-16' ]]; then
      log_wifi_stats wlp4s0 &
      log_wifi_stats_pid=$!
      sync_images
    else
      # Connect to network and sync images
      nmcli device wifi connect EMLI-TEAM-16
      if [[ $? -eq 0 ]]; then
        echo "Connected to wifi"
        log_wifi_stats wlp4s0 &
        log_wifi_stats_pid=$!
        sync_images
      else
        echo "Could not connect to wifi"
      fi
    fi
  fi
  sleep 1
done

trap "echo 'Stopping wifi logging'; kill $log_wifi_stats_pid" EXIT
