#!/bin/bash

local_time=$(date +"%a %Y-%m-%d %H:%M:%S %Z")
echo "Drone system time ($local_time)"

ssh_connection="emli@10.0.0.10"
echo "Disabling auto sync"
ssh "$ssh_connection" "sudo timedatectl set-ntp false"
echo "Manually setting time"
ssh "$ssh_connection" "sudo timedatectl set-time '$local_time'"

remote_time=$(ssh "$ssh_connection" "timedatectl status | grep 'Local time' | sed 's/^.*Local time: *//'")
echo "Wildlife cam system time ($remote_time)"
