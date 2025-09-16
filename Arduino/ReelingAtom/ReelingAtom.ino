// Reeling Mechanism
#include <M5StickCPlus2.h>
#include "M5_RoverC.h"
#include "M5AtomS3.h"
#include <WiFi.h>
#include <PID_v1.h>
#include <Wire.h>


#define encoderPin1 38
#define encoderPin2 39


// m5atoms3
const int IN1_PIN = 6;
const int IN2_PIN = 7;
int freq          = 10000;
int ledChannel1   = 0;
int ledChannel2   = 1;
int resolution    = 10;
bool direction    = true;
int VIN_PIN       = 8;
int FAULT_PIN     = 5;


// PID values setup
String readString; //This while store the user input data
long User_Input = 0; // This while convert input string into integer
float speed;
volatile int lastEncoded = 0; // Here updated value of encoder store.
volatile long encoderValue = 0; // Raw encoder value
bool is_travelling_down = false;


//long PPR_shaft = (long)210.5906*12;  // Encoder Pulse per revolution of the shaft (Probably more like encoder resolution). Supposed to be Gear Ratio * 360/(ppr spec), for some reason not this case
//long PPR_shaft = (long)380*120/4.2;
long PPR_shaft = 30 * 12;
int angle = 360; // Maximum degree of motion.
long REV = 0;          // Set point REQUIRED ENCODER VALUE
int lastMSB = 0;
int lastLSB = 0;
double kp = 0.2 , ki = 0.002 , kd = 0.15;        //RPM Control only kp non-zero, Position control: kp and kd non-zero, Position and RPM all non-zero
double input = 0, output = 0, setpoint = 0;
int previousOut = 0;
PID myPID(&input, &output, &setpoint, kp, ki, kd, DIRECT);

int prevTime;
bool prevStateStill = true;
int motorIndex = 0;
const int timeThreshold = 100; //in milliseconds




// External Wifi
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
    auto cfg = M5.config();
    AtomS3.begin(cfg);


    M5.Lcd.setRotation(1);
    canvas.createSprite(160, 80);
    canvas.setTextColor(ORANGE);
    roverc.setSpeed(0, 0, 0);


    canvas.setTextDatum(MC_DATUM);
    //canvas.drawString("RoverC TEST", 80, 40, 4);
    canvas.pushSprite(0, 0);


    Serial.begin(115200);


    Wire.begin();
    Wire.setClock(400000);


    AtomS3.Display.setTextColor(GREEN);
    AtomS3.Display.setTextDatum(middle_center);
    AtomS3.Display.setFont(&fonts::Orbitron_Light_24);
    AtomS3.Display.setTextSize(1);
    AtomS3.Display.setRotation(AtomS3.Display.getRotation()^3);
    //AtomS3.Display.drawString("H-Driver", AtomS3.Display.width() / 2,
    //                          AtomS3.Display.height() / 2);


    ledcSetup(ledChannel1, freq, resolution);
    ledcSetup(ledChannel2, freq, resolution);
    ledcAttachPin(IN1_PIN, ledChannel1);
    ledcAttachPin(IN2_PIN, ledChannel2);
    pinMode(VIN_PIN, INPUT);
    pinMode(FAULT_PIN, INPUT);
    ledcWrite(ledChannel1, 0);
    ledcWrite(ledChannel2, 0);


    pinMode(encoderPin1,INPUT_PULLUP);
    pinMode(encoderPin2,INPUT_PULLUP);


    //Where PID Setup bigins
    digitalWrite(encoderPin1, HIGH);  //turn pullup resistor on
    digitalWrite(encoderPin2, HIGH);  //turn pullup resistor on


    //call updateEncoder() when any high/low changed seen
    //on interrupt 0 (pin 2), or interrupt 1 (pin 3)
    attachInterrupt(digitalPinToInterrupt(encoderPin1), updateEncoder, CHANGE);
    attachInterrupt(digitalPinToInterrupt(encoderPin2), updateEncoder, CHANGE);


    myPID.SetMode(AUTOMATIC);   //set PID in Auto mode
    myPID.SetSampleTime(1);  // refresh rate of PID controller
    myPID.SetOutputLimits(-950, 950); // this is the MAX PWM value to move motor, here change in value reflect change in speed of motor.


    // External Wifi
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED){
      delay(500);
      Serial.print("Connecting");
    }
    Serial.println("WiFi connected. IP address: ");
    Serial.println(WiFi.localIP());
    server.begin();

    prevTime= millis();
}


void loop() {
  updateBatteryDisplay();


  int command;
  WiFiClient client = server.available();
  encoderValue = 0;
  if (client) {
    Serial.println("New Client");
    while (client.connected()) {
      if (client.available()) {
        client.read((uint8_t *)&command, sizeof(int));
        client.read((uint8_t *)&speed, sizeof(float));
        Serial.print("Command: ");
        Serial.print(command);
        Serial.print("Speed: ");
        Serial.println(speed);
      }
      User_Input = command;
      control();
    }
  }
}


void updateBatteryDisplay() {
  int batteryPercent = M5.Power.getBatteryLevel();
  if (batteryPercent < 0) {
      // If getBatteryLevel() fails, use a fallback method to display battery status
      float batteryVoltage = M5.Power.getBatteryVoltage();
      if (batteryVoltage > 0) {
          batteryPercent = map(batteryVoltage * 1000, 3300, 4200, 0, 100);  // Adjust mapping as per battery voltage range
      } else {
          batteryPercent = -1;  // Indicates that battery info is unavailable
      }
  }
  AtomS3.Display.clear();
  AtomS3.Display.drawString("Battery:", AtomS3.Display.width() / 2, AtomS3.Display.height() / 4);
  AtomS3.Display.drawString(String(batteryPercent) + "%", AtomS3.Display.width() / 2, AtomS3.Display.height() / 2);
}


void control(){
  //REV = map (User_Input, 0, 360, 0, PPR_shaft); // mapping degree into pulse
  //Serial.println(User_Input);
  REV = User_Input * PPR_shaft/360;
  //Serial.print("this is REV - ");
  //Serial.println(REV);               // printing REV value  


  setpoint = REV;                    //PID while work to achive this value consider as SET value
  input = encoderValue ;           // data from encoder consider as a Process value
  //Serial.print("encoderValue - ");
  //Serial.println(encoderValue);
  myPID.Compute();                 // calculate new output
  pwmOut(output, encoderValue, REV);
}


void pwmOut(int out, volatile long encoderValue, long REV) {      //Test for 0 case to see if fixes oscillation issue                          
  // original motor: max 1023, no min, diff 70
  // 1:5 motor: max 1023, min 950, diff 10  
  // 1:10 motor: max 1023, min 900, diff 10
  //Serial.print("PWM Val: ");
  //Serial.println(out);


  //Rate Limiting Logic
  int maxDelta = 1;


  int delta = out-previousOut;
  if(abs(delta) > maxDelta){
    out = previousOut + (delta >0 ? maxDelta: -maxDelta);
  }
  previousOut = out;


  if(out<0 && abs(out)> 600){
    is_travelling_down = true;
  }
  /*goal is to give balloon enough time to stop moving downwards when
  //  it is moving downwarnds so that the shift to moving upwards doesn't
  //  cause the string to bunch up.*/
  if(is_travelling_down && out>500){
    delay(1500);
    is_travelling_down=false;
  }


  out = round(speed * out);                  
  if ((out > 0) && (abs(encoderValue-REV) > 10)) {                     // if REV > encoderValue motor move in forward direction.    
    if(prevStateStill){
      prevStateStill = false;
      prevTime = millis();
    }
    if (millis() - prevTime >= timeThreshold){
      motorIndex += 1;
    }
    if(motorIndex % 2 ==1){
      if(out> 550){
        forward(600);
      } else if(out<500){
        forward(500);
      }
      else{
        forward(out);  // calling motor to move forward
      }
    }
  }
  else if((out<0) && (abs(encoderValue-REV) > 10)) {
    if(abs(out) > 1023){
      reverse(1023);
    } else if(abs(out)<500){
        reverse(500);
    }
    else {
      reverse(abs(out));  // calling motor to move reverse
    }
  } else{
    prevStateStill = true;
    stop();
  }
 //readString=""; // Cleaning User input, ready for new Input
}


void updateEncoder(){
  int MSB = digitalRead(encoderPin1); //MSB = most significant bit
  int LSB = digitalRead(encoderPin2); //LSB = least significant bit


  int encoded = (MSB << 1) |LSB; //converting the 2 pin value to single number
  int sum  = (lastEncoded << 2) | encoded; //adding it to the previous encoded value


  if(sum == 0b1101 || sum == 0b0100 || sum == 0b0010 || sum == 0b1011) encoderValue ++;
  if(sum == 0b1110 || sum == 0b0111 || sum == 0b0001 || sum == 0b1000) encoderValue --;


  lastEncoded = encoded; //store this value for next time


}


void forward(int out){
  ledcWrite(ledChannel1, out);
  ledcWrite(ledChannel2, 0);
}


void reverse(int out){
  ledcWrite(ledChannel1, 0);
  ledcWrite(ledChannel2, out);
}


void stop(){
  ledcWrite(ledChannel1, 0);
  ledcWrite(ledChannel2, 0);
}



