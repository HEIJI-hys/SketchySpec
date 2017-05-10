#include <Servo.h>

Servo myservo;

void setup() {
  myservo.attach(2);
  Serial.begin(9600);
}

void loop() {
  if (Serial.available() > 0) { // only when you receive data:
    byte incoming;
    incoming = Serial.read();
    switch (incoming) {
      case 's':
        scan();
        break;
      case 'l':
        int pos;
        pos = 19;
        while (pos == 19) {
          if (Serial.available() > 0) {
            pos = (int)Serial.read();
          }
        }
        lambda(pos);
        break;
      case 'r':
        float n;
        for (int j = 0; j < 3; j++) {
          delay(300);
          n += analogRead(A5);
        }
        n = n / 3;
        Serial.println(n);
        break;
    }
  }
}

void scan() {
  // Scanning through the entire spectrum
  int n, j;
  int start = 20;
  int fin = 130;
  int pos = 0;
  for (pos = start; pos <= fin; pos += 1) {
    myservo.write(pos);
    //Serial.println(pos);
    n = 0;
    for (j = 0; j < 3; j++) {
      delay(300);
      n += analogRead(A5);
    }
    n = n / 3;
    Serial.print(pos);
    Serial.print(',');
    Serial.println(n);
  }
}

void lambda(int pos) {
  myservo.write(pos);
}

