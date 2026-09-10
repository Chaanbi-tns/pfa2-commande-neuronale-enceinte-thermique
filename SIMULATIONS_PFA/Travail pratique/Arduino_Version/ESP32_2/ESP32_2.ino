// ============================================================
//  MVC + Réseau de Neurones — ESP32
//  Calcul ET envoi CSV dans le même programme
//  Import MATLAB : data = readmatrix('COM3'); (ou copier/coller)
// ============================================================

// --- Poids NN ---
#define W0  0.5f
#define W1  1.2f
#define W2 -0.8f
//===========================Implementation du capteur DHT11
//#include <DHT11.h>
//DHT11 dht11(2);
#define N      100     // nombre d'échantillons
#define N1      30     // palier 1 → palier 2
#define N2      60     // palier 2 → palier 3
#define IMAX    10     // itérations gradient
#define MU      0.2f   // pas d'apprentissage
#define LAMBDA  0.001f // pondération régularisation
#define ALPHA   1.0f   // correction prédiction
#define TE      2000   // période échantillonnage (ms)
// --- Variables d'état (les seules nécessaires) ---
float uk = 0, yk = 0;  // commande et sortie précédentes

// --- Consigne inline ---
float yc(int k) {
  if (k < N1) return 0.3f;
  if (k < N2) return 0.6f;
  return 0.5f;
}

void setup() {
  //Serial.begin(9600); this baude rate is for DHT11 Sensor
  Serial.begin(115200);
  delay(500);
  Serial.println("k,yc,ys,uc");  // en-tête CSV

  for (int k = 2; k < N; k++) {

    // 1 — Sortie système réel
    float ys = -0.8f * (uk*uk / (1 + uk*uk)) * yk
               + 0.033f * yk + 0.5f * uk;

    // 2 — Prédiction NN
    float yp = tanhf(-W0 + W1*uk + W2*yk);

    // 3 — Optimisation commande (descente de gradient)
    float x = uk;
    for (int i = 0; i < IMAX; i++) {
      float tv  = tanhf(-W0 + W1*x + W2*ys);
      float dJ  = -2*(yc(k+1) - tv - ALPHA*(ys-yp)) * (1-tv*tv) * W1
                  + 2*LAMBDA*(x - uk);
      x -= MU * dJ;
    }

    // 4 — Envoi CSV
// 4 — Envoi avec labels pour le Traceur Série Arduino
Serial.print("Consigne:");  Serial.print(yc(k), 4);
Serial.print(",Sortie:");   Serial.print(ys,    4);
Serial.print(",Commande:"); Serial.println(x,   4);
    Serial.println(x,   4);

    // 5 — Mise à jour état
    uk = x;  yk = ys;

    delay(TE);
  }
  Serial.println("FIN");
}

void loop() {
  /*   int temperature = dht11.readTemperature();
         if (temperature != DHT11::ERROR_CHECKSUM && temperature != DHT11::ERROR_TIMEOUT) {
        Serial.print("Temperature: ");
        Serial.print(temperature);
        Serial.println(" °C");
    } else {
        // Print error message based on the error code.
        Serial.println(DHT11::getErrorString(temperature));
    }
  */

} 
