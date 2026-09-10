#include "DHT.h"

#define DHTPIN 4
#define DHTTYPE DHT22

DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(115200);
  dht.begin();
  delay(2000); // Stabilisation DHT
}

void loop() {
  for (int k = 3; k <= 20; k++) {
    float t = dht.readTemperature();
    
    if (isnan(t)) {
      Serial.println("Erreur DHT");
      delay(2000);
      k--; // Réessayer le même k
      continue;
    }

    float Power = k * 10.0; // Valeur fictive juste pour tester : 30, 40, 50

    // Format CSV : k,t,Power
Serial.print(k);
Serial.print(" ");
Serial.print(t, 2);
Serial.print(" ");
Serial.println(Power, 2);

    delay(2000);
  }
  Serial.println("FIN DE SIMULATION");
  while (true); // Arrêt après les 3 mesures
}