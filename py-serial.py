import serial
import paho.mqtt.client as mqtt
import json
import time

SERIAL_PORT = '/dev/ttyACM1'
BAUD_RATE = 115200

MQTT_BROKER = "10.0.0.10"
MQTT_TOPIC = "sensor/wiper"

client = mqtt.Client(protocol=mqtt.MQTTv5)  

def on_connect(client, userdata, flags, rc, properties=None):
    if rc == 0:
        print("Connected successfully to MQTT broker")
    else:
        print(f"Failed to connect, return code {rc}")

def on_disconnect(client, userdata, rc, properties=None):
    if rc != 0:
        print("Unexpected disconnection.")
    else:
        print("Disconnected from MQTT broker")

client.on_connect = on_connect
client.on_disconnect = on_disconnect

def ensure_mqtt_connection():
    while True:
        try:
            client.connect(MQTT_BROKER, 1883, 60)
            break  
        except Exception as e:
            print("Connection failed, retrying in 2 seconds:", str(e))
            time.sleep(2)  

ensure_mqtt_connection()
client.loop_start()  

try:
    with serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1) as ser:
        print("Serial port opened")
        while True:
            try:
                line = ser.readline().decode('utf-8').strip()
                if line:
                    print("Received:", line)
                    data = json.loads(line)
                    if data.get('rain_detect') == 1:
                        print("Rain detected! Sending MQTT message...")
                        client.publish(MQTT_TOPIC, "use wiper")
            except serial.SerialException as e:
                print("Serial port error:", e)
            except json.JSONDecodeError:
                print("Error decoding JSON")
            time.sleep(0.1)
except Exception as e:
    print("An unexpected error occurred:", e)

client.loop_stop()  
client.disconnect()  
