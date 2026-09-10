#include <RBDdimmer.h> 
#include "DHT.h"
#include <math.h>

// --- Pins ---
#define outputPin  12   
#define zerocross  14   
#define DHTPIN 4
#define DHTTYPE DHT22

// --- Objets ---
dimmerLamp dimmer(outputPin, zerocross); 
DHT dht(DHTPIN, DHTTYPE);

//Paramétres du systéme 
float W1[10][2] = {
    { 0.2435,  0.1039},
    { 0.1075, -0.0419},
    {-0.2757,  0.1360},
    { 0.1781, -0.0686},
    {-0.1860, -0.1063},
    { 0.3933,  0.0599},
    {-0.5292, -0.0327},
    {-0.3627,  0.0875},
    { 0.4581,  0.0179},
    {-0.4537,  0.0130}
};
float W2[10] = {
    0.2186, 0.1256, -0.2973, 0.1862, -0.2256, 0.3729, -0.5812, -0.3181, 0.4623, -0.4557
};
float b1[10] = {
     0.0698,
     0.1025,
     0.0218,
     0.0586,
     0.0305,
     0.0903,
    -0.0505,
     0.0251,
     0.0810,
    -0.0285
};
float b2 = -0.0715;
float v = 0;
//Paramétres de commande par minimum de variance
float alpha = 1;
float lambda = 0.1;
float x;
float mu = 0.1;
float dJ;
int imax = 30;
//Pourcentage commande gradateur
float Power;
int k = 3;
const int N = 2000;

// --- Variables de commande ---
float u[N+2];
float yc[N+2];
float y[N+2];
float y_p[2000];
// forwardPass prédit, computeGradient oriente la recherche de la commande optimale par minimum de variance.
float forwardPass(float y_in, float u_in) {
  float hidden[10];
  for (int i = 0; i < 10; i++) {
    hidden[i] = b1[i]
              + W1[i][0] * y_in
              + W1[i][1] * u_in;
    hidden[i] = tanh(hidden[i]);
  }
  float out = b2;
  for (int i = 0; i < 10; i++) {
    out += W2[i] * hidden[i];
  }
  return tanh(out);
}
// Gradient  dy/du  par backpropagation
float computeGradient(float y_in, float u_in) {
  float hidden[10], v_out;
  v_out = b2;
  for (int i = 0; i < 10; i++) {
    float net = b1[i]
              + W1[i][0] * y_in
              + W1[i][1] * u_in;
    hidden[i] = tanh(net);
    v_out += W2[i] * hidden[i];
  }
  float d_out = 1.0f - pow(tanh(v_out), 2);   // dérivée sortie
  float dydx = 0.0f;
  for (int i = 0; i < 10; i++) {
    float d_h = 1.0f - hidden[i] * hidden[i];  // dérivée cachée
    dydx += W2[i] * d_h * W1[i][1];            // W1[i][1] → poids lié à u
  }
  return dydx * d_out;
}
void setup() {
  Serial.begin(115200);
  dht.begin();

  dimmer.begin(NORMAL_MODE, ON); 
  dimmer.setPower(0); 

  for (int i = 0; i < N +1; i++) {
    yc[i] = 0.35;//Ici la valeur de la consigne
    u[i] = 0;
    y[i] = 0;
    y_p[i] = 0;
  }
}

void loop() {

  float t = dht.readTemperature();

  if (isnan(t)) {
    Serial.println("Erreur DHT");
    delay(2000);
    return;
  }

  // --- Normalisation ---
    y[k] = t / 100.0;

  // --- Modèle ---
  y_p[k] = forwardPass(y[k - 1], u[k - 1]);
  // ── Initialisation optimisation ────────────────────────────
  float x = u[k - 1];
  // ── Descente de gradient ───────────────────────────────────
  for (int i = 0; i < imax; i++) {

    float yp_next = forwardPass(y[k], x);
    yp_next      += alpha * (y[k] - y_p[k]);     // correction erreur modèle

    float dydx = computeGradient(y[k], x);

    float dJ = -2.0f * (yc[k + 1] - yp_next) * dydx
               + 2.0f * lambda * (x - u[k - 1]);

    x -= mu * dJ;
  }
  // --- Mise à jour commande ---
  u[k] = x;
  // --- Saturation ---
  if (u[k] > 1) u[k] = 1;
  if (u[k] < 0) u[k] = 0;

  // --- Conversion en puissance ---
  Power = u[k] * 100.0f;
  if (Power > 100) Power = 100;
  if ( Power < 0 ) Power = 0;
  dimmer.setPower(Power);

  // --- Affichage ---
  Serial.print("Temp: ");
  Serial.print(t);
  Serial.print(" °C | Power: ");
  Serial.println(Power);
  Serial.println(u[k]);

  //delay(2000);

  // --- Incrément ---
  k++;
  if (k >= N + 1) k = 3;
}
