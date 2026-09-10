// ============================================================
//  Commande Minimum de Variance avec Réseau de Neurones
//  ESP32 - Arduino IDE
//  Calcul + affichage à chaque itération
//  Te ajusté selon durée réelle de calcul
// ============================================================

#include "SPIFFS.h"
//#include <DHT11.h>
//DHT11 dht11(2);
//#define CS_PIN 5 //Pin ship select
// -------- Paramètres NN --------
const float w0 =  0.5f;
const float w1 =  1.2f;
const float w2 = -0.8f;

// -------- Paramètres algorithme --------
const int   IMAX   = 10;
const float MU     = 0.2f;
const float LAMBDA = 0.001f;
const float ALPHA  = 1.0f;
const long  Te     = 200; // période en ms

// -------- Simulation --------
const int N  = 100;
const int N1 = 30;
const int N2 = 60;

// -------- Tableaux résultats --------
float uc[N];
float ys[N];
float yp[N];
float yc[N];

bool done = false;

// ============================================================
// SETUP
// ============================================================
void setup() {
  //Serial.begin(9600); BAUDE POUR LE DHT11
  Serial.begin(115200);
  delay(1000);
  // -------- Initialiser SPIFFS --------
  if (!SPIFFS.begin(true)) {
    Serial.println("Erreur montage SPIFFS");
    return;
  }
  // Supprimer ancien fichier si existant
  if (SPIFFS.exists("/data.csv")) {
    SPIFFS.remove("/data.csv");
  }
  // Écrire l'en-tête CSV
  File f = SPIFFS.open("/data.csv", FILE_WRITE);
  if (f) {
    f.println("k,Consigne,Sortie,Commande");
    f.close();
  }

  // -------- Initialisation tableaux --------
  for (int i = 0; i < N; i++) {
    uc[i] = 0.0f;
    ys[i] = 0.0f;
    yp[i] = 0.0f;
    yc[i] = 0.0f;
  }

  // Consigne
  for (int i = 0;  i < N1; i++) yc[i] = 0.3f;
  for (int i = N1; i < N2; i++) yc[i] = 0.6f;
  for (int i = N2; i < N;  i++) yc[i] = 0.5f;

  // Conditions initiales
  uc[0] = 0;
  uc[1] = 0;
  ys[0] = 0;
  ys[1] = 0;
}

// ============================================================
// LOOP : calcul + affichage avec Te ajusté
// ============================================================
void loop() {
  //int temperature = dht11.readTemperature();Instanciation de la température
  //Exception d'erreur sur la lecture de la température
  /*  if (temperature != DHT11::ERROR_CHECKSUM && temperature != DHT11::ERROR_TIMEOUT) {
        Serial.print("Temperature: ");
        Serial.print(temperature);
        Serial.println(" °C");
    } else {
        // Print error message based on the error code.
        Serial.println(DHT11::getErrorString(temperature));
    }*/
  if (done) return;

  float ys_scalaire;
  float yp_scalaire;
  float uc_scalaire;

  int k = 3;
  while (k < N-1) {

    // -------- mesurer début itération --------
    unsigned long start_time = micros();

    // -------- Système réel --------
    ys_scalaire =
      -0.8f*(uc[k-1]*uc[k-1]/(1.0f + uc[k-1]*uc[k-1]))*ys[k-1]
      + 0.033f*ys[k-1]
      + 0.5f*uc[k-1];

    // -------- Prédiction NN --------
    float v0 = -w0 + w1*uc[k-1] + w2*ys[k-1];
    yp_scalaire = tanhf(v0);
    uc_scalaire = uc[k-1];

    int i = 0;
    while (i < IMAX) {

      float v = -w0 + w1*uc_scalaire + w2*ys_scalaire;
      float t = tanhf(v);
      float yp_nxt = t + ALPHA*(ys_scalaire - yp_scalaire);
      float df = 1.0f - t*t;
      float dJ = -2.0f*(yc[k+1]-yp_nxt)*df*w1 + 2.0f*LAMBDA*(uc_scalaire-uc[k-1]);

      uc_scalaire -= MU*dJ;
      i++;
    }

    // -------- mémorisation tableaux --------
    ys[k] = ys_scalaire;
    uc[k] = uc_scalaire;
//Début écriture dans le fichier,le fichier data.csv n'est pas un fichier physique mais est un texte qui s'affiche sur le moniteur série 
    // -------- écriture fichier CSV --------
    File f = SPIFFS.open("/data.csv", FILE_APPEND);
    if (f) {
      f.print(k);
      f.print(",");
      f.print(yc[k], 4);
      f.print(",");
      f.print(ys[k], 4);
      f.print(",");
      f.println(uc[k], 4);
      f.close();
    }

    /// -------- affichage traceur série --------
    Serial.print("Consigne:");
    Serial.println(yc[k], 4);
    Serial.print(",");
    Serial.print("Sortie:");
    Serial.println(ys[k], 4);
    Serial.print(",");
    Serial.print("Commande:");
    Serial.println(uc[k], 4);
/*Serial.print(k);
Serial.print(",");
Serial.print(yc[k], 4);
Serial.print(",");
Serial.print(ys[k], 4);
Serial.print(",");
Serial.println(uc[k], 4);*/

    // -------- mesurer fin itération --------
    unsigned long duration_us = micros() - start_time;

    // -------- ajuster le delay pour respecter Te --------
    long delay_us = (long)(Te * 1000L) - (long)duration_us;
    if (delay_us > 0) {
      delayMicroseconds((unsigned long)delay_us);
    }

    k++;
  }

  // -------- envoi fichier CSV vers PC via Serial --------
  delay(2000);
  Serial.println("\n--- DEBUT FICHIER CSV ---");
  File f = SPIFFS.open("/data.csv", FILE_READ);
  if (f) {
    while (f.available()) {
      Serial.write(f.read());
    }
    f.close();
  }
  Serial.println("--- FIN FICHIER CSV ---");

  done = true;
}