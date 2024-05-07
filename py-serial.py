import serial
import time

serial_port = '/dev/ttyACM0'
baud_rate = 115200

try:
    ser = serial.Serial(serial_port, baud_rate)
    while True:
        if ser.in_waiting > 0:
            line = ser.readline().decode('utf-8').strip()
            print("Received:", line)
        time.sleep(0.1)
except serial.SerialException as e:
    print("Error opening serial port:", e)
except KeyboardInterrupt:
    print("Exiting...")
finally:
    ser.close()
