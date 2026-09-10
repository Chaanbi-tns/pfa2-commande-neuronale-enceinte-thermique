import serial
import time

Save_To_Path = r"C:\Users\user\Desktop\2AGE2\PFA2_AGE2\SIMULATIONS_PFA\Travail pratique\Commande_MV_1NN\Data_4000.txt"

try:
    ser = serial.Serial('COM9', 115200, timeout=1)
    time.sleep(2)
    print("✅ Connexion établie")
except Exception as e:
    print(f"❌ Erreur port série : {e}")
    exit()

try:
    with open(Save_To_Path, "w", encoding="utf-8") as file:
        file.write("k,t,Power\n")
        print("📂 En attente des données...")

        while True:
            if ser.in_waiting > 0:
                line = ser.readline().decode('utf-8', errors='ignore').strip()
                
                if not line:
                    continue

                    print(f"Reçu : {line}")

                if "FIN DE SIMULATION" in line:
                    print("\n🏁 Simulation terminée.")
                    break

                if line[0].isdigit():
                   file.write(line + "\n")
                   file.flush()
                   print(f"✅ Enregistré : {line}")

except KeyboardInterrupt:
    print("\n🛑 Arrêt manuel.")

finally:
    if 'ser' in locals() and ser.is_open:
        ser.close()
        print("🔌 Port fermé.")