import processing.serial.*;
import oscP5.*;
import netP5.*;
import processing.net.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

Serial myPort;
Client[] clients;
//String[] ips = {"172.20.10.5"};
String[] ips = {"192.168.0.101"};
//String[] ips = {"172.20.10.5","172.20.10.10"};
//String[] ips = {"192.168.0.103", "192.168.0.104"};
int port = 5204;
boolean controlRoverC = true; // To track control mode

// constants
int nCubes = 2;
int cubesPerHost = 12;
int maxMotorSpeed = 115;
int xOffset;
int yOffset;

int nRobots = ips.length;
boolean trackingMode = true;
boolean targetingMode = true;

int[] matDimension = {45, 45, 455, 455};
float matSize = 1.0; //The size (m) of the space for visualizing the RoverC 

// for OSC
OscP5 oscP5;
// where to send the commands to
NetAddress[] server;

// we'll keep the cubes here
Cube[] cubes;
// Additional variables for circular motion
float angle = 0;
float radius = 100;

// RoverC variables
Robot[] robots;

void settings() {
  size(1000, 1000);
}

void setup() {
  //frameRate(15);
  frameRate(60);
  
  // launch OSC server
  oscP5 = new OscP5(this, 3333);
  server = new NetAddress[1];
  server[0] = new NetAddress("127.0.0.1", 3334);

  // create cubes
  cubes = new Cube[nCubes];
  for (int i = 0; i < nCubes; ++i) {
    cubes[i] = new Cube(i);
  }

  xOffset = matDimension[0] - 45;
  yOffset = matDimension[1] - 45;

  // do not send TOO MANY PACKETS
  frameRate(30);

  // Initialize wifi
  println("Connecting to WiFi...");
  //myClient = new Client(this, "10.150.74.205", 5204);
  clients = new Client[ips.length];
  for (int i = 0; i < ips.length; i++) {
    clients[i] = new Client(this, ips[i], port);
    println("Connecting to " + ips[i]);
    delay(1000); 
  }
  
  // Initialize RoverC variables
  robots = new Robot[nRobots];
  for (int i = 0; i < nRobots; i++){
    robots[i] = new Robot(i,false); //id:i, isActive:false
  }
}

void draw() {
  background(255);
  stroke(0);
  long now = System.currentTimeMillis();

  if (!controlRoverC) {
    // Draw the Toio platform
    drawToioPlatform(now);
  } else {
    // Draw the RoverC platform
    drawRoverCPlatform();
  }

  // Draw the button to switch control mode
  fill(200);
  rect(850, 20, 120, 40);
  fill(0);
  textSize(16);
  textAlign(CENTER, CENTER);
  text(controlRoverC ? "Control Toio" : "Control RoverC", 910, 40);

  if (mousePressed && mouseX >= 850 && mouseX <= 970 && mouseY >= 20 && mouseY <= 60) {
    controlRoverC = !controlRoverC;
  }
}

void drawToioPlatform(long now) {
  // Draw the "mat"
  fill(255);
  rect(matDimension[0] - xOffset, matDimension[1] - yOffset, matDimension[2] - matDimension[0], matDimension[3] - matDimension[1]);

  // Draw the cubes
  pushMatrix();
  translate(xOffset, yOffset);

  for (int i = 0; i < nCubes; i++) {
    cubes[i].checkActive(now);

    if (cubes[i].isActive) {
      pushMatrix();
      translate(cubes[i].x, cubes[i].y);
      fill(0);
      textSize(15);
      text(i, 0, -20);
      noFill();
      rotate(cubes[i].theta * PI / 180);
      rect(-10, -10, 20, 20);
      line(0, 0, 20, 0);
      popMatrix();
    }
  }
  popMatrix();

  // Move Cube 0 in a circle
  float x = 200 + radius * cos(angle);
  float y = 200 + radius * sin(angle);
  cubes[0].target((int)x, (int)y, 0);
  angle += 0.05;

  // Rotate Cube 1 360 degrees clockwise and counterclockwise
  int rotateSpeed = 50;
  int duration = 1000; // milliseconds
  if (frameCount % (2 * duration) < duration) {
    cubes[1].motor(rotateSpeed, -rotateSpeed, duration);
  } else {
    cubes[1].motor(-rotateSpeed, rotateSpeed, duration);
  }
}

void drawRoverCPlatform() {
  // draw target position
  pushMatrix();
    translate(width/2, height/2);
    stroke(0,255,0);
    line(0, 0, 0, -100/matSize);
    stroke(255,0,0);
    line(0, 0, 100/matSize, 0);
    stroke(0,0,0);
  popMatrix();
  fill(255,0,0,100);
  //if moving target, delete this comment out
  for(int i = 0; i < nRobots; i++){
    if(robots[i].isActive){
      robots[i].setTargetPosition(new PVector(mouseX-width/2,mouseY-height/2));
      robots[i].setTargetSet(true);
      robots[i].initPID();
    }
  }
  ellipse(mouseX,mouseY,20,20);
  
  //draw buttons to activate/deactivate each RoverC
  for (int i = 0; i < nRobots; i++) {
    fill(robots[i].isActive ? 0 : 200);
    rect(20, 20 + i * 40, 120, 30);
    fill(robots[i].isActive ? 255 : 0);
    text("RoverC " + (i + 1) + (robots[i].isActive ? " On" : " Off"), 80, 35 + i * 40);
  }
  
  if (mousePressed) {
    for (int i = 0; i < nRobots; i++) {
      if (mouseX >= 20 && mouseX <= 140 && mouseY >= 20 + i * 40 && mouseY <= 50 + i * 40) {
        robots[i].isActive = !robots[i].isActive;
      }
    }
  }
  
  if (keyPressed) {
    if(key == '0'){
      robots[0].isActive = !robots[0].isActive;
    }else if(key == '1'){
      robots[1].isActive = !robots[1].isActive;
    }
  }
  
  // Key press events for RoverC control
  for (int i = 0; i < clients.length; i++) {
    if (clients[i].active()) {
      if(targetingMode == false){
        if (keyPressed && robots[i].isActive) {
          if(trackingMode == false){
            PVector currentPos = robots[i].getPosition();
            if (key == 'f') {
              clients[i].write('f');
              currentPos.y -= 5;
            } else if (key == 'b') {
              clients[i].write('b');
              currentPos.y += 5;
            } else if (key == 'l') {
              clients[i].write('l');
              currentPos.x -= 5;
            } else if (key == 'r') {
              clients[i].write('r');
              currentPos.x += 5;
            } else {
              clients[i].write('s');
            }
            robots[i].setPosition(currentPos);
          }else{
            if (key == 'f') {
              clients[i].write('f');
            } else if (key == 'b') {
              clients[i].write('b');
            } else if (key == 'l') {
              clients[i].write('l');
            } else if (key == 'r') {
              clients[i].write('r');
            } else {
              clients[i].write('s');
            }
          }
        }
        if(!keyPressed){
         clients[i].write('s');
        }
      }else{
        if(robots[i].targetSet){
          if(trackingMode){
            if(keyPressed && key == 's' || !robots[i].isActive){
              clients[i].write('s');
            }else{
              robots[i].moveToTarget(clients[i]);
            }
            
          }else{
            robots[i].moveToTargetSimulator();
          }
        }
      }
      robots[i].drawRobot(matSize);
    }
    else {
      println("Client " + i + " disconnected, attempting to reconnect...");
      clients[i] = new Client(this, ips[i], port);
      println("Connecting to " + ips[i]);
    }
  }
}

void mousePressed(){
  for(int i = 0; i < nRobots; i++){
    if(robots[i].isActive){
      robots[i].setTargetPosition(new PVector(mouseX-width/2,mouseY-height/2));
      //targetSet = true;
      robots[i].setTargetSet(true);
      robots[i].initPID();
    }
  }
}
