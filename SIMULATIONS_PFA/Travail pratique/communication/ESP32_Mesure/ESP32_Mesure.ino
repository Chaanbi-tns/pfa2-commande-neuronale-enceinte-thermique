//Ce proagramme est pour upload à la carte esp32 type micro usb
#include <esp_now.h>
#include <WiFi.h>
#include "DHT.h"
#include <RBDdimmer.h>

// ─── Pins ─────────────────────────────────────────────────────
#define outputPin  12
#define zerocross  14
#define DHTPIN      4
#define DHTTYPE   DHT22

// ─── Objets ───────────────────────────────────────────────────
dimmerLamp dimmer(outputPin, zerocross);
DHT        dht(DHTPIN, DHTTYPE);

// ─── Adresse MAC de l'ESP32-A (à adapter) ────────────────────
// MAC A : c0:cd:d6:ca:5a:50
uint8_t controllerAddress[] = {0xC0, 0xCD, 0xD6, 0xCA, 0x5A, 0x50};

// ─── Structures ESP-NOW ───────────────────────────────────────
typedef struct {
  float power; // commande reçue du contrôleur (0–100 %)
} MsgFromA;

typedef struct {
  float temperature; // mesure à envoyer au contrôleur
} MsgToA;

volatile float receivedPower = 0.0;
volatile bool  newPowerReady = false;
MsgToA tempMsg;

// ─── Callbacks ESP-NOW ────────────────────────────────────────
void onSent(const uint8_t *mac, esp_now_send_status_t status) {
  // optionnel
}

void onReceive(const uint8_t *mac_addr,   // ← remplace esp_now_recv_info_t *info
               const uint8_t *data, int len) {
  if (len == sizeof(MsgFromA)) {
    MsgFromA msg;
    memcpy(&msg, data, sizeof(msg));
    receivedPower = msg.power;
    newPowerReady = true;
  }
}

// ─── Setup ────────────────────────────────────────────────────
void setup() {
  Serial.begin(115200);
  dht.begin();
  dimmer.begin(NORMAL_MODE, ON);
  dimmer.setPower(0);

  WiFi.mode(WIFI_STA);

  if (esp_now_init() != ESP_OK) {
    Serial.println("Erreur init ESP-NOW");
    return;
  }
  esp_now_register_send_cb(onSent);
  esp_now_register_recv_cb(onReceive);

  // Enregistrement du pair (ESP32-A)
  esp_now_peer_info_t peerInfo = {};
  memcpy(peerInfo.peer_addr, controllerAddress, 6);
  peerInfo.channel = 0;
  peerInfo.encrypt = false;
  if (!esp_now_is_peer_exist(controllerAddress)) {
    esp_now_add_peer(&peerInfo);
  }
}

// ─── Loop ─────────────────────────────────────────────────────
void loop() {
  // ── Lecture de la température ──────────────────────────────
  float t = dht.readTemperature();
  if (isnan(t)) {
    Serial.println("Erreur DHT");
    delay(2000);
    return;
  }

  // ── Envoi de la mesure au contrôleur ───────────────────────
  tempMsg.temperature = t;
  esp_now_send(controllerAddress, (uint8_t *)&tempMsg, sizeof(tempMsg));

  // ── Application de la dernière commande reçue ──────────────
  if (newPowerReady) {
    newPowerReady = false;
    dimmer.setPower((int)receivedPower);
    Serial.print("Power appliquée : ");
    Serial.println(receivedPower, 2);
  }

  delay(2000);
}