#!/bin/bash

# MQTT Broker settings
BROKER_IP="10.0.0.10"
TOPIC_SUBSCRIBE="/sensor/wiper"
TOPIC_PUBLISH="/wiper/on"

cleanup() {
    echo "Cleaning up..."

    exit 0
}

# Waiting for CRTL + C
trap cleanup SIGINT SIGTERM

# Subs to mqtt topic 
mosquitto_sub -h $BROKER_IP -t $TOPIC_SUBSCRIBE | while read msg
do
    # Prints msq and looks for "rain detect"
    echo "Received message: $msg"
    rain_detect=$(echo "$msg" | jq '.rain_detect')
    
    # Publishes to topic if rain is detected (Rain_detect: 1)
    if [[ $rain_detect -eq 1 ]]; then
        echo "Rain detected! Activating wipers."
        mosquitto_pub -h $BROKER_IP -t $TOPIC_PUBLISH -m "activate"
    fi
done

# Adding cleanup command
cleanup
