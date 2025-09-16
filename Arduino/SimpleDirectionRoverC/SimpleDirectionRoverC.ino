#include <M5StickCPlus2.h>
#include "M5_RoverC.h"
#include <WiFi.h>

//static const char *ssid = "roverc";
//static const char *password = "password";
//const IPAddress ip(10, 150, 74, 205);
//const IPAddress netmask(255, 255, 255, 0);

// External Wifi
const char* ssid = "TP-Link_ABF8";
const char* password = "46072955";
//const char* ssid = "MiyuPhone";
//const char* password = "miyuyuyumi";

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

    // Start WiFi access point
    /*
    WiFi.mode(WIFI_AP);
    WiFi.softAP(ssid, password);
    delay(100);
    WiFi.softAPConfig(ip, ip, netmask);
    IPAddress myIP = WiFi.softAPIP();
    Serial.print("AP started. My IP address: ");
    Serial.println(myIP);
    server.begin();
    Serial.println("Server started");*/

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
            if (client.available()) {
                char command = client.read();
                Serial.print("Received: ");
                Serial.println(command);
                if (command == 'f') {
                    roverc.setSpeed(0, 100, 0);
                } else if (command == 'b') {
                    roverc.setSpeed(0, -100, 0);
                } else if (command == 'l') {
                    roverc.setSpeed(-100, 0, 0);
                } else if (command == 'r') {
                    roverc.setSpeed(100, 0, 0);
                } else if (command == 's') {
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