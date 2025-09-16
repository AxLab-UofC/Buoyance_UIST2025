#include <M5StickCPlus2.h>
#include "M5_RoverC.h"
#include <WiFi.h>

// External Wifi
//const char* ssid = "MiyuPhone";
//const char* password = "miyuyuyumi";
//const char* ssid = "TP-Link_ABF8";
//const char* password = "46072955";
const char* ssid = "TP-Link_0294";
const char* password = "02030050";

WiFiServer server(5204);

M5Canvas canvas = M5Canvas(&M5.Lcd);
M5_RoverC roverc;

void setup() {
    M5.begin();
    roverc.begin();

    M5.Lcd.setRotation(1);
    canvas.createSprite(160, 80);
    canvas.setTextColor(ORANGE);
    roverc.setSpeed(0, 0, 0);

    canvas.setTextDatum(MC_DATUM);
    canvas.drawString("RoverC TEST", 80, 40, 4);
    canvas.pushSprite(0, 0);

    Serial.begin(9600);

    // External Wifi
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED){
      delay(500);
      Serial.print(".");
    }
    Serial.println("WiFi connected. IP address: ");
    Serial.println(WiFi.localIP());
    server.begin();
}

void loop() {
    WiFiClient client = server.available();
    if (client) {
        Serial.println("New Client");
        while (client.connected()) {
            if (client.available() > 0) {
              char command = client.read();
                if(command == 's'){
                  Serial.println("Stop");
                  roverc.setSpeed(0, 0, 0);
                }else if(command == 'p'){
                  float speedX, speedY;
                  client.read((uint8_t *)&speedX, sizeof(float));
                  client.read((uint8_t *)&speedY, sizeof(float));
                  // int8_t speedX, speedY;
                  // speedX = client.read();
                  // speedY = client.read();

                  Serial.print("Speed X: ");
                  Serial.print(speedX);
                  Serial.print(", Speed Y: ");
                  Serial.print(speedY);

                  // speedX_int8 = (int8_t)constrain(round(speedX), -128, 127);
                  // speedY_int8 = (int8_t)constrain(round(speedY), -128, 127);

                  Serial.print("   int8_t : ");
                  Serial.print("Speed X: ");
                  Serial.print(speedX);
                  Serial.print(", Speed Y: ");
                  Serial.println(speedY);

                  roverc.setSpeed(speedX, speedY, 0);
                }else{
                  roverc.setSpeed(0, 0, 0);
                }
                delay(10);
            }
        }
        client.stop();
        Serial.println("Client Disconnected");
    }
    delay(100);
}
