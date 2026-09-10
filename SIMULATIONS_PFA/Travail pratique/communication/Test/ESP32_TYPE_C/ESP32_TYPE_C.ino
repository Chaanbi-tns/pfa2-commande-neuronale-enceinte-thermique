// ============================================================
//  ESP32 - Carte Type C qui sera placé coté maquette  (BIDIRECTIONNEL)
//  Émet ses propres u_A, T_A  ET  reçoit u_B, T_B de la Carte B
// ============================================================

#include <esp_now.h>
#include <WiFi.h>

// ⚠️  Adresse MAC de la Carte micro usb (à relever depuis le Serial de B)
uint8_t adresseMAC_B[] = {0xA8, 0x42, 0xE3, 0x9E, 0x97, 0xA8};
//a8:42:e3:9e:97:a8
typedef struct Message {
  float u;   // Commande
  float T;   // Température
} Message;

Message aEnvoyer;
Message aRecevoir;

void onEnvoi(const uint8_t *mac, esp_now_send_status_t statut) {
  Serial.println(statut == ESP_NOW_SEND_SUCCESS
    ? "[A→B] ✅ Envoi réussi"
    : "[A→B] ❌ Envoi échoué");
}


// ✅ Correct pour core 2.0.17
void onReception(const uint8_t *mac, const uint8_t *data, int len) {
  if (len == sizeof(Message)) {
    memcpy(&aRecevoir, data, sizeof(aRecevoir));
    Serial.printf("[A←B] Reçu → u=%.3f  T=%.2f°C\n", aRecevoir.u, aRecevoir.T);
  }
}

void setup() {
  Serial.begin(115200);
  delay(500);

  WiFi.mode(WIFI_STA);
  Serial.print("[A] Mon adresse MAC : ");
  Serial.println(WiFi.macAddress());

  if (esp_now_init() != ESP_OK) {
    Serial.println("[A] ERREUR ESP-NOW init");
    while (true);
  }

  esp_now_register_send_cb(onEnvoi);
  esp_now_register_recv_cb(onReception);

  // Ajout de la Carte B comme pair
  esp_now_peer_info_t pair = {};
  memcpy(pair.peer_addr, adresseMAC_B, 6);
  pair.channel = 0;
  pair.encrypt = false;

  if (esp_now_add_peer(&pair) != ESP_OK) {
    Serial.println("[A] ERREUR ajout pair B");
    while (true);
  }

  Serial.println("[A] Prêt — émission + réception actives");
}

void loop() {
  static float t = 0.0f;

  // Simulation des données de A
  aEnvoyer.u = 1.5f * sin(t);
  aEnvoyer.T = 25.0f + 5.0f * cos(t);

  Serial.printf("[A→B] Envoi  → u=%.3f  T=%.2f°C\n", aEnvoyer.u, aEnvoyer.T);
  esp_now_send(adresseMAC_B, (uint8_t *)&aEnvoyer, sizeof(aEnvoyer));

  t += 0.3f;
  delay(2000);
}