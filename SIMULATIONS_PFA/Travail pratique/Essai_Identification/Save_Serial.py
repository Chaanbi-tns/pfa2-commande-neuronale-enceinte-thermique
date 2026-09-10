import serial
import time

ser = serial.Serial('COM6', 115200, timeout=1)
time.sleep(2) 

print("Saving to sensor_log.txt... Press Ctrl+C to stop.")

try:

    with open("fichier_3.txt", "a") as file:
        while True:
            line1 = ser.readline().decode('utf-8').strip()

            if line1:
                
                log_entry = f"{line1}\n"
                print(log_entry)

                file.write(log_entry)
                file.flush() 

except KeyboardInterrupt:
    print("\nRecording stopped.")
finally:
    ser.close()

