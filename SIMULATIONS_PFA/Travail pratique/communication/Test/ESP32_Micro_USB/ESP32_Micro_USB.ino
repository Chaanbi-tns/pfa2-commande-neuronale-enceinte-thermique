// ============================================================
//  ESP32 - Carte micro usb (BIDIRECTIONNEL)
//  Émet ses propres u_B, T_B  ET  reçoit u_A, T_A de la Carte A
// ============================================================

#include <esp_now.h>
#include <WiFi.h>

// ⚠️  Adresse MAC de la Carte type C (à relever depuis le Serial de A)
uint8_t adresseMAC_A[] = {0xC0, 0xCD, 0xD6, 0xCA, 0x5A, 0x50};
//c0:cd:d6:ca:5a:50
typedef struct Message {
  float u;   // Commande
  float T;   // Température
} Message;

Message aEnvoyer;
Message aRecevoir;

void onEnvoi(const uint8_t *mac, esp_now_send_status_t statut) {
  Serial.println(statut == ESP_NOW_SEND_SUCCESS
    ? "[B→A] ✅ Envoi réussi"
    : "[B→A] ❌ Envoi échoué");
}
void onReception(const uint8_t *mac, const uint8_t *data, int len) {
  if (len == sizeof(Message)) {
    memcpy(&aRecevoir, data, sizeof(aRecevoir));
    Serial.printf("[B←A] Reçu → u=%.3f  T=%.2f°C\n", aRecevoir.u, aRecevoir.T);
  }
}

void setup() {
  Serial.begin(115200);
  delay(500);

  WiFi.mode(WIFI_STA);
  Serial.print("[B] Mon adresse MAC : ");
  Serial.println(WiFi.macAddress());

  if (esp_now_init() != ESP_OK) {
    Serial.println("[B] ERREUR ESP-NOW init");
    while (true);
  }

  esp_now_register_send_cb(onEnvoi);
  esp_now_register_recv_cb(onReception);

  // Ajout de la Carte A comme pair
  esp_now_peer_info_t pair = {};
  memcpy(pair.peer_addr, adresseMAC_A, 6);
  pair.channel = 0;
  pair.encrypt = false;

  if (esp_now_add_peer(&pair) != ESP_OK) {
    Serial.println("[B] ERREUR ajout pair A");
    while (true);
  }

  Serial.println("[B] Prêt — émission + réception actives");
}

void loop() {
  static float t = 0.0f;

  // Simulation des données de B (déphasées pour les distinguer)
  aEnvoyer.u = 2.0f * cos(t);
  aEnvoyer.T = 30.0f + 3.0f * sin(t);

  Serial.printf("[B→A] Envoi  → u=%.3f  T=%.2f°C\n", aEnvoyer.u, aEnvoyer.T);
  esp_now_send(adresseMAC_A, (uint8_t *)&aEnvoyer, sizeof(aEnvoyer));

  t += 0.3f;
  delay(2000);
}