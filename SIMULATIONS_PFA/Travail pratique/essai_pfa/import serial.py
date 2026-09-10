import serial
import time
import os
Save_To_Path = "C:\\Users\\user\\Desktop\\2AGE2\\PFA2_AGE2\\SIMULATIONS_PFA\\Travail pratique\\essai_pfa\\fichier_3.txt"
ser = serial.Serial('COM4', 115200, timeout=1)
time.sleep(2)

# ✅ Crée le fichier immédiatement même sans données
with open("Save_To_Path", "a") as file:
    file.write(f"=== Session démarrée : {time.strftime('%Y-%m-%d %H:%M:%S')} ===\n")
    file.flush()

print(f"Fichier : {os.path.abspath('fichier_3.txt')}")
print("Saving to fichier_3.txt... Press Ctrl+C to stop.")

try:
    with open("Save_To_Path", "a") as file:
        while True:
            line1 = ser.readline().decode('utf-8').strip()

            if line1:
                log_entry = f"{time.strftime('%H:%M:%S')} | {line1}\n"  # ✅ timestamp
                print(log_entry)
                file.write(log_entry)
                file.flush()
            else:
                print("En attente de données...")  # ✅ debug si rien reçu

except KeyboardInterrupt:
    print("\nRecording stopped.")
finally:
    ser.close()