#include <RBDdimmer.h> 
#include "DHT.h"

#define outputPin  12   
#define zerocross  14   

#define DHTPIN 4
#define DHTTYPE DHT22

dimmerLamp dimmer(outputPin, zerocross); 
DHT dht(DHTPIN, DHTTYPE);

int brightness = 50; 

float u[2000];
float Power;
int k = 1;
int i=0;

void setup() {
  Serial.begin(115200);
  dht.begin();

  dimmer.begin(NORMAL_MODE, ON); 
  dimmer.setPower(brightness);   

  for (i=0;i<501;i++) u[i]=1.5;
  for (i=501;i<801;i++) u[i]=1.75;
  for (i=801;i<1301;i++) u[i]=0.25;
  for (i=1301;i<1601;i++) u[i]=2;
  for (i=1601;i<1801;i++) u[i]=0.2;
  for (i=1801;i<2001;i++) u[i]=1.8;
}

void loop() {

  float t = dht.readTemperature();

  if (isnan(t)) {
    Serial.println("ERR");
    delay(2000);
    return;
  }

  if (u[k] > 5) u[k] = 5;
  if (u[k] < 0) u[k] = 0;

  Power = u[k] * 20;
  if (Power > 100) Power = 100;

  dimmer.setPower(Power);

  Serial.print(t);
  Serial.println("°C");

  delay(2000);
  yield();

  k++;
  if (k >= 2001) k = 1;   
}