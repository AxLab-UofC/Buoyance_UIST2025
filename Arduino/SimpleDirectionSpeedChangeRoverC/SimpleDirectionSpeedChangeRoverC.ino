

// RoverC: non targeting
#include <M5StickCPlus2.h>
#include "M5_RoverC.h"
#include <WiFi.h>

// External Wifi
//const char* ssid = "TP-Link_ABF8";
//const char* password = "46072955";
//const char* ssid = "MiyuPhone";
//const char* password = "miyuyuyumi";
const char* ssid = "TP-Link_0294_5G";
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
    //canvas.drawString("RoverC TEST", 80, 40, 4);
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

void updateDisplay(const String &direction) {
    // Get the battery voltage and map it to percentage
    //float batteryVoltage = M5.Power.getBatteryVoltage();
    int batteryPercent = M5.Power.getBatteryLevel(); 

    canvas.fillSprite(BLACK);
    canvas.setTextDatum(MC_DATUM);
    canvas.setTextColor(ORANGE);
    canvas.drawString("Battery:" + String(batteryPercent) + "%", 80, 20, 4);
    canvas.drawString("Move:" + direction, 80, 60, 4);
    canvas.pushSprite(0, 0);
}

void loop() {
    WiFiClient client = server.available();
    if (client) {
        Serial.println("New Client");
        while (client.connected()) {
            if (client.available() > 0) {
              char command = client.read();
              String direction = "Stop";
                if(command == 's'){
                  Serial.println("Stop");
                  roverc.setSpeed(0, 0, 0);
                }else{
                  float speed;
                  client.read((uint8_t *)&speed, sizeof(float));
                  Serial.print("Speed: ");
                  Serial.println(speed);
                  if (command == 'f') {
                    roverc.setSpeed(0, speed * 100, 0);
                    direction = "Forward";
                  } else if (command == 'b') {
                      roverc.setSpeed(0, - (speed * 100), 0);
                      direction = "Backward";
                  } else if (command == 'l') {
                      roverc.setSpeed(- (speed * 100), 0, 0);
                      direction = "Left";
                  } else if (command == 'r') {
                      roverc.setSpeed(speed * 100, 0, 0);
                      direction = "Right";
                  }
                }
                updateDisplay(direction);
                delay(10);
            }
        }
        client.stop();
        Serial.println("Client Disconnected");
    }
    delay(100);
}
