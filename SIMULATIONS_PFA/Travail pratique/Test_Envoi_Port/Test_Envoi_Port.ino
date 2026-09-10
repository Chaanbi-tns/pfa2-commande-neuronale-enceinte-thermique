int k = 0;

void setup() {
  Serial.begin(115200);
  delay(2000);
}

void loop() {
  float t = 20.0 + 20.0 * sin(k * 0.1);

  float power = (t - 20.0) * 5.0;
  if (power > 100) power = 100;
  if (power < 0)   power = 0;

  Serial.print("Temp: ");
  Serial.print(t, 2);
  Serial.print(" °C | Power: ");
  Serial.println(power, 2);

  k++;
  delay(2000);
}