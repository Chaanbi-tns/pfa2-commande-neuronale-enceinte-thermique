#include <esp_now.h>
#include <WiFi.h>
#include <math.h>

// ─── Taille des tableaux ───────────────────────────────────────
#define N 4000

// ─── Paramètres du modèle ─────────────────────────────────────
float w0 = 0.0499, w1 = 0.6055, w2 = 0.5768;
float w3 = 0.005,  w4 = 0.0084;
float v  = 0;

// ─── Paramètres de commande (minimum de variance) ─────────────
float alpha  = 1.0;
float lambda = 0.1;
float mu     = 0.1;
float x, dJ;
int   imax   = 30;

// ─── Variables globales ───────────────────────────────────────
float Power = 0.0;
int   k     = 3;

float u[N];
float y[N];
float y_p[N];
float yc[N];

// ─── Adresse MAC de l'ESP32-B (à adapter) ────────────────────
// MAC B : a8:42:e3:9e:97:a8
uint8_t peerAddress[] = {0xa8, 0x42, 0xE3, 0x9E, 0x97, 0xA8};
// ─── Structures ESP-NOW ───────────────────────────────────────
typedef struct {
  float power;   // commande envoyée à l'actionneur (0–100 %)
} MsgToB;

typedef struct {
  float temperature; // mesure renvoyée par l'actionneur
} MsgFromB;

MsgToB   outMsg;
volatile float receivedTemp = NAN;
volatile bool  newTempReady = false;

// ─── Callbacks ESP-NOW ────────────────────────────────────────
void onSent(const uint8_t *mac, esp_now_send_status_t status) {
  // optionnel : Serial.println(status == ESP_NOW_SEND_SUCCESS ? "OK" : "FAIL");
}

void onReceive(const uint8_t *mac_addr,
               const uint8_t *data, int len) {
  if (len == sizeof(MsgFromB)) {
    MsgFromB msg;
    memcpy(&msg, data, sizeof(msg));
    receivedTemp = msg.temperature;
    newTempReady = true;
  }
}

// ─── Setup ────────────────────────────────────────────────────
void setup() {
  Serial.begin(115200);
  WiFi.mode(WIFI_STA);

  if (esp_now_init() != ESP_OK) {
    Serial.println("Erreur init ESP-NOW");
    return;
  }
  esp_now_register_send_cb(onSent);
  esp_now_register_recv_cb(onReceive);

  // Enregistrement du pair (ESP32-B)
  esp_now_peer_info_t peerInfo = {};
  memcpy(peerInfo.peer_addr, peerAddress, 6);
  peerInfo.channel = 0;
  peerInfo.encrypt = false;
  if (!esp_now_is_peer_exist(peerAddress)) {
    esp_now_add_peer(&peerInfo);
  }

  // Initialisation des tableaux
  for (int i = 0; i < N; i++) {
    u[i] = 0.0; y[i] = 0.0; y_p[i] = 0.0;
    yc[i] = (i < N / 2) ? 0.4f : 0.5f;
  }
}

// ─── Loop ─────────────────────────────────────────────────────
void loop() {
  // ── Timestamp début calcul (avant réception) ──────────────
  unsigned long t_start = millis();
	
  // Attente d'une nouvelle mesure de température (envoyée par ESP32-B)
  unsigned long t0 = millis();
  //unsigned long start_time = micros();
  while (!newTempReady && millis() - t0 < 5000) delay(10);

  if (!newTempReady) {
    Serial.println("Timeout : pas de mesure reçue");
    delay(2000);
    return;
  }
  newTempReady = false;
  float t = receivedTemp;

  if (isnan(t)) {
    Serial.println("Température invalide");
    delay(2000);
    return;
  }

  // ── Normalisation ──────────────────────────────────────────
  y[k] = t / 100.0f;

  // ── Modèle d'identification (prédiction courante) ──────────
  v      = -w0 + w1*y[k-1] + w2*y[k-2] + w3*u[k-1] + w4*u[k-2];
  y_p[k] = tanhf(v);

  // ── Initialisation de la variable d'optimisation ──────────
  x = u[k - 1];

  // ── Boucle d'optimisation (descente de gradient) ──────────
  for (int i = 0; i < imax; i++) {
    v           = -w0 + w1*y[k] + w2*y[k-1] + w3*x + w4*u[k-1];
    y_p[k + 1]  = tanhf(v);
    y_p[k + 1] += alpha * (y[k] - y_p[k]);  // correction d'erreur
    float df    = 1.0f - powf(tanhf(v), 2);
    dJ = -2.0f * (yc[k+1] - y_p[k+1]) * df * w3
         + 2.0f * lambda * (x - u[k-1]);
    x -= mu * dJ;
  }

  // ── Mise à jour et saturation [0, 1] ──────────────────────
  u[k] = x;
  if (u[k] > 1.0f) u[k] = 1.0f;
  if (u[k] < 0.0f) u[k] = 0.0f;

  // ── Conversion en pourcentage ──────────────────────────────
  Power = u[k] * 100.0f;
  if (Power > 100.0f) Power = 100.0f;
  if (Power <   0.0f) Power = 0.0f;

  // ── Envoi de la commande à ESP32-B ─────────────────────────
  outMsg.power = Power;
  esp_now_send(peerAddress, (uint8_t *)&outMsg, sizeof(outMsg));
  
   // ── Calcul ΔT (durée calcul + envoi uniquement) ───────────
  unsigned long deltaT = millis() - t_start;

  // ── Attente pour compléter Te = 2s ────────────────────────
  long wait = 2000L - (long)deltaT;
  if (wait > 0) delay((unsigned long)wait);

  // ── Affichage série ────────────────────────────────────────
  Serial.print(k);
  Serial.print("  T="); Serial.print(t, 2);
  Serial.print("  P="); Serial.println(Power, 2);

  // ── Incrément avec protection débordement ──────────────────
  k++;
  if (k >= N - 1) k = 3;
}