#!/bin/bash

# MQTT Broker settings
BROKER_IP="10.0.0.10"
TOPIC="/sensor/wiper"
TOPIC_ON="/wiper/on"

# Serial port settings
SERIAL_PORT="/dev/ttyACM0"
BAUD_RATE="115200"

# Check if serial port is available
if [ ! -c "$SERIAL_PORT" ]; then
    echo "Error: Serial port $SERIAL_PORT not found!"
    exit 1
fi

# Configure serial port
stty -F $SERIAL_PORT $BAUD_RATE raw

# Function to send wipe command (0-180-0)
send_commands() {
    echo "{'wiper_angle': 0}" > $SERIAL_PORT
    echo "{'wiper_angle': 180}" > $SERIAL_PORT
    echo "{'wiper_angle': 0}" > $SERIAL_PORT
}

# Function to clean up background processes
cleanup() {
    echo "Cleaning up..."
    # Kill the publishing backgroud process
    kill $PUB_PID
    exit 0
}

# Waiting for CRTL + C
trap cleanup SIGINT SIGTERM

# Read data from serial port and publish to MQTT in the background
cat $SERIAL_PORT | while read LINE
do
    mosquitto_pub -h $BROKER_IP -t $TOPIC -m "$LINE"
done &
# Store process id for kill later
PUB_PID=$! 

# Initialize the command lock
COMMAND_LOCK=0

# Subscribe to MQTT topic 
mosquitto_sub -h $BROKER_IP -t $TOPIC_ON | while read msg
do
    # Chekcs if recieved message is equal "activate"
    if [[ "$msg" == "activate" ]] && [[ $COMMAND_LOCK -eq 0 ]]; then
        COMMAND_LOCK=1  # Set lock to block further commands
        send_commands
        COMMAND_LOCK=0  # Release lock after commands are sent
    fi
done
