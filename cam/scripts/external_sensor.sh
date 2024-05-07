#!/bin/bash

# MQTT Broker settings
BROKER_IP="10.0.0.10"
TOPIC="/trigger/external"

# Path to the script
SCRIPT="./take_photo.sh external"

# Function to handle messages
message_received() {
    echo "Message received on $TOPIC, running take_photo.sh"
    $SCRIPT
}

# Loop to listen for mqtt messages
mosquitto_sub -h $BROKER_IP -t $TOPIC | while read msg
do
    message_received "$msg"
done
