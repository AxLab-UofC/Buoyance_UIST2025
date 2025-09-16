// GUI control pannel
import peasy.PeasyCam;
PeasyCam cam;
import controlP5.*;
ControlP5 cp5;
//Slider2D objectXYControl;
PVector objectXYControl;
float xy, z;
float[] dataX, dataY, dataZ;
float[] bodyX, bodyY, bodyZ;
float handX, handY, handZ;
float[] gestureX, gestureX_prev, gestureX_sum, gestureY, gestureY_prev, gestureY_sum, gestureZ_init, gestureZ_prev, gestureZ_sum;
int gesture_status = 0;
String controlX = "none";
String controlY = "none";

float speed = 0.006;
int avoid = 0;
int[] lifting;
Slider zControl, xySpeed, zSpeed, pitchControl, yawControl, rollControl, stringAngleControl;
Toggle mouseToggle, joystickToggle, dataToggle, bodyToggle, simToggle, modeToggle, trackingToggle, assemblyToggle, liftingToggle;
RadioButton simRadio;
Button selectButton;
Numberbox maxSpeed;
Accordion accordion;
PGraphics pg2D;
import java.awt.event.KeyEvent;

// joystick
import org.gamecontrolplus.*;
ControlIO control;
ControlDevice joystick;

// byte buffer : To send speed data as a byte to an Arduino.
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

// communicate with server to control RoverC
import processing.serial.*;
import processing.net.*;
Client[] clients_xy;
Client[] clients_z;

// communicate with unity 
import oscP5.*;
import netP5.*;
OscP5 oscP5; // for OSC
NetAddress[] server; // where to send the commands to

//Rigbots, Balloons
Balloon[] balloons;
//CombinedBalloon[] combinedBalloons;
ArrayList<CombinedBalloon> combinedBalloons;
RigBot[] bots;
OmniBot[] omnibots;
Reel[] reels;
ConnectionPoint[] cps;
Obstacles[] obstacles;


//first object's/connection point's position(x,y,z)
PVector initPoint;
PVector initPoint2;
PVector initPoint3;

int selectedObject = 0;
int selectedObject_1 = -1, selectedObject_2 = -1;
int selectedCombinedObject = 0;
PVector mouseInView;

//Open and Closed Hand images
PImage openHand;  //refers to left hand
PImage closedHand;  // refers to left hand
PImage openRightHand;
PImage closedRightHand;

/* -------------------------------------------------------------------------- */
/*                           initialization + setup                           */
/* -------------------------------------------------------------------------- */

//screen size setting
void settings() {
  if (!enable3Dview) size(ViewerWidth, ViewerHeight);
  else size(ViewerWidth, ViewerHeight, P3D);
}

void setup(){
  // launch OSC server
  oscP5 = new OscP5(this, 3333);
  server = new NetAddress[1];
  server[0] = new NetAddress("127.0.0.1", 3334);
  if(bodyControl){
    sendState();
  }
  
  // Initialize wifi for xy
  println("Connecting to WiFi for RoverC ...");
  clients_xy = new Client[ips_xy.length];
  for (int i = 0; i < ips_xy.length; i++) {
    clients_xy[i] = new Client(this, ips_xy[i], port);
    println("Connecting to " + ips_xy[i]);
    delay(1000); 
  }
  
  // Initialize wifi for z
  println("Connecting to WiFi for Atom ...");
  clients_z = new Client[ips_z.length];
  for (int i = 0; i < ips_z.length; i++) {
    clients_z[i] = new Client(this, ips_z[i], port);
    println("Connecting to " + ips_z[i]);
    delay(1000); 
  }
  
  // Init rigbots
  omnibots = new OmniBot[nBots];
  reels = new Reel[nBots];
  bots = new RigBot[nBots];
  for (int i = 0; i < nBots; i++){
    omnibots[i] = new OmniBot();
    reels[i] = new Reel();
    if(dataControl || (bodyControl && bodyControl_display)){
      bots[i] = new RigBot(i,true, omnibots[i], reels[i]); 
    }
    else{
      if(i == selectedObject){
        bots[i] = new RigBot(i,true, omnibots[i], reels[i]); //id:i, isActive:true
      }else{
        bots[i] = new RigBot(i,false, omnibots[i], reels[i]); //id:i, isActive:false
      }
    }
  }
  
  if(nObstacles > 0){
    obstacles = new Obstacles[nObstacles];
    for (int i = 0; i < nObstacles; i++){
      obstacles[i] = new Obstacles();
      //obstacles[i].setPosition(new PVector(100, -100, 300));
    }
    obstacles[0].size = 300;
    obstacles[1].size = 530; // 21 cm in reality and 120 * 2 in GUI
    obstacles[2].size = 250;
  }
   
  // Init connection points and balloon
  cps = new ConnectionPoint[nBots];
  balloons = new Balloon[nBalloons];
  
  initPoint = new PVector(100, 100, botHeight);
  initPoint = new PVector(0, 0, botHeight);
  initPoint2 = new PVector(200, 100, botHeight);
  initPoint3 = new PVector(200, 100, botHeight);
  
  //single bot example:
  lifting = new int[nBalloons];
  for(int i = 0; i < nBalloons; i++){
    lifting[i] = 0;
    initPoint = new PVector(random(0,200),random(0,200),botHeight);
    cps[i] = new ConnectionPoint(i, initPoint, bots[i]);
    if(dataControl || (bodyControl && bodyControl_display)){
       balloons[i] = new Balloon(i, true, new ConnectionPoint[]{cps[i]}); //id:i, isActive:true
    }
    else{
     if(i == selectedObject){
        balloons[i] = new Balloon(i, true, new ConnectionPoint[]{cps[i]}); //id:i, isActive:true
      }else{
        balloons[i] = new Balloon(i, false, new ConnectionPoint[]{cps[i]}); //id:i, isActive:false
      }
    }
  }
  
  //single bot example:
   //cps[0] = new ConnectionPoint(0, initPoint, bots[0]);
   //balloons[0] = new Balloon(0, new ConnectionPoint[]{cps[0]});

  //two bots example: one object
  //cps[0] = new ConnectionPoint(0, initPoint, bots[0]);
  //cps[1] = new ConnectionPoint(1, cps[0], dist[0], bots[1]);
  //balloons[0] = new Balloon(0, true, new ConnectionPoint[]{cps[0], cps[1]});
  
  //cps[2] = new ConnectionPoint(2, initPoint2, bots[2]);
  //cps[3] = new ConnectionPoint(3, cps[2], dist[1], bots[3]);
  //balloons[1] = new Balloon(1, false, new ConnectionPoint[]{cps[2], cps[3]});
  
  //two bots example: two objects
  //cps[0] = new ConnectionPoint(0, initPoint, bots[0]);
  //cps[1] = new ConnectionPoint(1, initPoint2, bots[1]);
  //balloons[0] = new Balloon(0, true, new ConnectionPoint[]{cps[0]});
  //balloons[1] = new Balloon(1, false, new ConnectionPoint[]{cps[1]});
  
  // init combined balloon
  combinedBalloons = new ArrayList<CombinedBalloon>();
  for(int i = 0; i < nBalloons; i++){
    ArrayList<Balloon> selectedBalloons = new ArrayList<Balloon>();
    selectedBalloons.add(balloons[i]);
    CombinedBalloon combinedBalloon = new CombinedBalloon(i, selectedBalloons);
    combinedBalloons.add(combinedBalloon);
  }
  
  // init data
  dataX = new float[nBalloons];
  dataY = new float[nBalloons];
  dataZ = new float[nBalloons];
  bodyX = new float[nBalloons];
  bodyY = new float[nBalloons];
  bodyZ = new float[nBalloons];
  waveZ = new float[nBalloons];
  openAngle = new float[nBalloons];
  gestureX = new float[nHands];
  gestureX_prev = new float[nHands];
  gestureX_sum = new float[nBalloons];
  gestureY = new float[nHands]; 
  gestureY_prev = new float[nHands];
  gestureY_sum = new float[nBalloons];
  gestureZ_init = new float[nHands]; 
  gestureZ_prev = new float[nHands];
  gestureZ_sum = new float[nBalloons];
  for(int i = 0; i < nBalloons; i++){
    for (ConnectionPoint c : balloons[i].connections)
    {
      dataX[i] = c.init.x;
      dataY[i] = c.init.y;
      dataZ[i] = c.init.z;
      bodyX[i] = c.init.x;
      bodyY[i] = c.init.y;
      bodyZ[i] = c.init.z;
    }
  }
  for(int i = 0; i < nHands; i++){
    tracking_gesture[i] = true;
    fist_count[i] = 0;
  }
  
  // init objectXYControl
  objectXYControl = new PVector(0,0);
  
  setupGUI();
  setupController();

  frameRate(appFrameRate);
  
  openHand = loadImage("OpenHand.png");
  closedHand = loadImage("ClosedHand.png");
  openRightHand = loadImage("OpenRightHand.png");
  closedRightHand = loadImage("ClosedRightHand.png");
}

/* -------------------------------------------------------------------------- */
/*                                draw function                               */
/* -------------------------------------------------------------------------- */

void draw(){
  mouseInView = new PVector(mouseX - XYViewCoordX,mouseY - XYViewCoordY);
  
  displayDebug();
  if (modeControl) {
    // AerorigUI
  } else {
    // Draw the RoverC platform
    drawRoverCPlatform();
  }  
  
}

boolean isControl = true;
boolean isSelectFlag = false;
void drawRoverCPlatform(){
  if(trackingMode && !targetingMode){
    objectXYControl = omnibots[selectedObject].getPosition();
  }
  
  if(dataControl){  // 9 robots with 9 balloons
    for(int i = 0; i < nBalloons; i++){
      if(dataMode != -1){
        if(dataMode == 0) {
          dataX[i] = lerp(dataX[i], 5.751343 + 120 * (i - (nBalloons / 2)) * 3, speed);
          dataY[i] = lerp(dataY[i], 4.5575714, speed);
          dataZ[i] = lerp(dataZ[i], 438.69482, speed);
          //print(dataX[i] + " " + dataY[i] + "\n");
        }
        if(dataMode == 1) {
          drawWave(i);
        } else if (dataMode == 2) {
          drawCircle(i);
        } else if (dataMode == 3) {
          drawElephant(i);
        } else if (dataMode == 4) {
          drawGiraffe(i);
        } else if (dataMode == 5) {
          drawOpening(i);
        }
        balloons[i].translateObject(new PVector(dataX[i]-150, dataY[i], dataZ[i]),0,0,0);
      }
    }
  } else if(bodyControl){
    if(gesture && targetingMode){
      // gesture status: 0 for 1-to-1 control, 1 and 2 for multi-robot control
      if(gesture_status == 0){
        if(nHands == 2){
           if(detectRobot(new PVector(gestureX[0], gestureY[0]), -1) != -1){
             selectedObject = detectRobot(new PVector(gestureX[0], gestureY[0]), -1);
           }
           if(tracking_gesture[1] == false && gestureZ_prev[0] != 0){
             gestureZ_sum[selectedObject] += 0.3 * (gestureZ_init[0] - gestureZ_prev[0]);
             if(gestureZ_sum[selectedObject] <= botHeight){
               gestureZ_sum[selectedObject] = botHeight;
             }
             balloons[selectedObject].translateObject(new PVector(gestureX[0], gestureY[0], gestureZ_sum[selectedObject]),0,0,0);
           }
        } else if(nHands == 4){
          if(detectRobot(new PVector(gestureX[0], gestureY[0]), -1) != -1){
             //selectedObject_1 = detectRobot(new PVector(gestureX[0], gestureY[0]), -1); //check the nearest
             selectedObject_1 = 0; // pre-defined
             if(tracking_gesture[1] == false && gestureZ_prev[0] != 0){
               gestureZ_sum[selectedObject_1] += 0.3 * (gestureZ_init[0] - gestureZ_prev[0]);
               if(gestureZ_sum[selectedObject_1] <= botHeight){
                 gestureZ_sum[selectedObject_1] = botHeight;
               }
               balloons[selectedObject_1].translateObject(new PVector(gestureX[0], gestureY[0], gestureZ_sum[selectedObject_1]),0,0,0);
             }
           }
           if(detectRobot(new PVector(gestureX[2], gestureY[2]), selectedObject_1) != -1){
             //selectedObject_2 = detectRobot(new PVector(gestureX[2], gestureY[2]), selectedObject_1); // check the nearest
             selectedObject_2 = 1; // pre-defined
             if(tracking_gesture[3] == false && gestureZ_prev[2] != 0){
               gestureZ_sum[selectedObject_2] += 0.3 * (gestureZ_init[2] - gestureZ_prev[2]);
               if(gestureZ_sum[selectedObject_2] <= botHeight){
                 gestureZ_sum[selectedObject_2] = botHeight;
               }
               balloons[selectedObject_2].translateObject(new PVector(gestureX[2], gestureY[2], gestureZ_sum[selectedObject_2]),0,0,0);
             }
           }
           //print("id: " +  selectedObject_1 + " " +  selectedObject_2 + "\n");
        }
      } 
      // 1 hand control multiple robots for xyz
      else if(gesture_status == 1){
        if(nHands == 2){
          if(detectRobot(new PVector(gestureX[0], gestureY[0]), -1) != -1){
             selectedObject = detectRobot(new PVector(gestureX[0], gestureY[0]), -1);
           }
           if(tracking_gesture[1] == false && gestureZ_prev[0] != 0){
             gestureZ_sum[selectedObject] += 0.3 * (gestureZ_init[0] - gestureZ_prev[0]);
             if(gestureZ_sum[selectedObject] <= botHeight){
               gestureZ_sum[selectedObject] = botHeight;
             }
             balloons[selectedObject].translateObject(new PVector(gestureX[0], gestureY[0], gestureZ_sum[selectedObject]),0,0,0);
             for(int i = 0; i < nBalloons; i++){
               if(i != selectedObject){
                   balloons[i].translateObject(new PVector(gestureX[0] + 215 * (i - selectedObject), gestureY[0], gestureZ_sum[selectedObject]),0,0,0);
               }
             }
           }
        }
      }
      // 2 hands control 4 robots for rotation
      else if(gesture_status == 2){
        if(nHands == 4){
          if(tracking_gesture[1] == false && gestureZ_prev[0] != 0 && tracking_gesture[3] == false && gestureZ_prev[2] != 0){
             gestureZ_sum[0] += 0.3 * (gestureZ_init[0] - gestureZ_prev[0]);
             if(gestureZ_sum[0] <= botHeight){
               gestureZ_sum[0] = botHeight;
             }
             balloons[0].translateObject(new PVector(gestureX[0], gestureY[0], gestureZ_sum[0]),0,0,0);
             gestureZ_sum[1] += 0.3 * (gestureZ_init[2] - gestureZ_prev[2]);
             if(gestureZ_sum[1] <= botHeight){
               gestureZ_sum[1] = botHeight;
             }
             balloons[1].translateObject(new PVector(gestureX[2], gestureY[2], gestureZ_sum[1]),0,0,0);
             // For the other 2 robots
             float dx = gestureX[2] - gestureX[0];
             float dy = gestureY[2] - gestureY[0];
             float px = - dy;
             float py = dx;
             balloons[2].translateObject(new PVector(gestureX[2] + px, gestureY[2] + py, gestureZ_sum[1]),0,0,0);
             balloons[3].translateObject(new PVector(gestureX[0] + px, gestureY[0] + py, gestureZ_sum[0]),0,0,0);
           }
        }
      }
    }
    if(bodyControl_display){
      for(int i = 0; i < nBalloons; i++){
        BodyTracking(i);
        balloons[i].translateObject(new PVector(bodyX[i], bodyY[i], bodyZ[i]),0,0,0);
      }
    }
    else{
      if(hand && targetingMode){
        balloons[selectedObject].translateObject(new PVector(handX, handY, handZ),0,0,0);
      }
      else{
        if(camera_hand){
          if(left.equals("up")){
            bodyZ[selectedObject] += 10;
          } else if (left.equals("down")){
            if(bodyZ[selectedObject] <= botHeight){
              bodyZ[selectedObject] = botHeight;
            } else {
              bodyZ[selectedObject] -= 10;
            }
          }
          if(targetingMode){
             if(right.equals("left")){
                bodyX[selectedObject] -= 45;
              }
              if(right.equals("right")){
                bodyX[selectedObject] += 45;
              }
              if(right.equals("up")){
                bodyY[selectedObject] -= 45;
              }
              if(right.equals("down")){
                bodyY[selectedObject] += 45;
              }
          }
          balloons[selectedObject].translateObject(new PVector(bodyX[selectedObject], bodyY[selectedObject], bodyZ[selectedObject]),0,0,0);
        }
      }
    }
  } else{
    if(mouseControl){
      if(mousePressed && mouseButton == LEFT && targetingMode && !(keyPressed && keyCode == ALT) && isControl){
        if(checkMouseInView()){
          objectXYControl.x = matScale*(mouseInView.x - stageWidth/2)+stageWidth/2 + stageCenterX;
          objectXYControl.y = matScale*(mouseInView.y - stageDepth/2)+stageDepth/2 + stageCenterY;
          
          // Handle Obstacle Avoidance Logic: check whether it already hit the obstacle or not
          avoid = 0;
          if(nObstacles > 0){
            for (int i = 0; i < nObstacles; i++) {
              PVector d = new PVector(obstacles[i].position.x - objectXYControl.x, obstacles[i].position.y -  objectXYControl.y);
              float s = obstacles[i].size;
              if(d.dot(d) - s * s < 0){
                avoid = -1;
              }
            }
          }
          for (int i = 0; i < nBots; i++) {
              if(i == selectedObject) continue;
              PVector d = new PVector(omnibots[i].position.x - objectXYControl.x, omnibots[i].position.y -  objectXYControl.y);
              float s = 40*mmToToio;
              if(d.dot(d) - s * s < 0){
                avoid = -2;
              }
          }
        }
      }
    }
    
    if(joystickControl){
      if(targetingMode){
        objectXYControl.x += joystick.getSlider(sliderName.RX.ordinal()).getValue()*10;
        objectXYControl.y += joystick.getSlider(sliderName.RY.ordinal()).getValue()*10;
      } else {
        if(joystick.getSlider(sliderName.RX.ordinal()).getValue()*10 > 0.3){
          controlX = "right";
        }
        else if (joystick.getSlider(sliderName.RX.ordinal()).getValue()*10 < -0.3) {
          controlX = "left";
        }
        else{
          controlX = "none";
        }       
        if(joystick.getSlider(sliderName.RY.ordinal()).getValue()*10 > 0.3){
          controlY = "down";
        }
        else if (joystick.getSlider(sliderName.RY.ordinal()).getValue()*10 < -0.3) {
          controlY = "up";
        }
        else{
          controlY = "none";
        }
      }
      
      zControl.setValue(zJoyStickUpdate(zControl.getValue()));
      yawControl.setValue(yawJoyStickUpdate(yawControl.getValue()));
      rollControl.setValue(rollJoyStickUpdate(rollControl.getValue()));
      pitchControl.setValue(pitchJoyStickUpdate(pitchControl.getValue()));
      
      if(joystick.getButton(buttonName.B.ordinal()).pressed() && !isSelectFlag){
        toggleObject(1);
      }
      isSelectFlag = joystick.getButton(buttonName.B.ordinal()).pressed();
    }
        
    if(assembly){
      ArrayList<CombinedBalloon> tmpCombinedBalloons = new ArrayList<CombinedBalloon>();;
      for(CombinedBalloon combinedBalloon : combinedBalloons){
        tmpCombinedBalloons = combinedBalloon.setCombinedBalloons();
        if(tmpCombinedBalloons != null){
          isControl = false;
          break;
        }else{
          tmpCombinedBalloons = combinedBalloons;
        }
      }
      combinedBalloons = tmpCombinedBalloons;
      for(CombinedBalloon combinedBalloon : combinedBalloons){
        combinedBalloon.id = tmpCombinedBalloons.indexOf(combinedBalloon);
      }
      if(!isControl){
        InitXYZControl(combinedBalloons.get(selectedCombinedObject), combinedBalloons.get(selectedCombinedObject).getMinHeight());
      }
      if(combinedBalloons.get(selectedCombinedObject).state == 0){
        combinedBalloons.get(selectedCombinedObject).translateObject(new PVector(objectXYControl.x,objectXYControl.y,zControl.getValue()),0,0,0);
      } else if(combinedBalloons.get(selectedCombinedObject).state == 1){
        combinedBalloons.get(selectedCombinedObject).translateObject(new PVector(objectXYControl.x,objectXYControl.y,zControl.getValue()),
                                                                     yawControl.getValue()  - combinedBalloons.get(selectedCombinedObject).yaw,
                                                                     0,
                                                                     pitchControl.getValue() - combinedBalloons.get(selectedCombinedObject).pitch);
      } else {
        combinedBalloons.get(selectedCombinedObject).translateObject(new PVector(objectXYControl.x,objectXYControl.y,zControl.getValue()),
                                                                     yawControl.getValue() - combinedBalloons.get(selectedCombinedObject).yaw,
                                                                     rollControl.getValue() - combinedBalloons.get(selectedCombinedObject).roll,
                                                                     pitchControl.getValue() - combinedBalloons.get(selectedCombinedObject).pitch);
      }
    }else{
      if(avoid == 0){
        for(int i = 0; i < nBalloons; i++){
          balloons[i].updateSelectedObject(mouseInView);
        }
        if(nBalloons == nBots/2){
          balloons[selectedObject].state = 1;
        }else{
          balloons[selectedObject].state = 0;
        }
        if(balloons[selectedObject].state == 0){
          balloons[selectedObject].translateObject(new PVector(objectXYControl.x,objectXYControl.y,zControl.getValue()),0,0,0);
        } else if(balloons[selectedObject].state == 1){
          balloons[selectedObject].translateObject(new PVector(objectXYControl.x,objectXYControl.y,zControl.getValue()),
                                                   yawControl.getValue() - balloons[selectedObject].yaw,
                                                   0,
                                                   pitchControl.getValue() - balloons[selectedObject].pitch);
        }
      }
    }
  }
  
  if(avoid == 0){
    if(wifiConnectionMode){
      control_xy();
      control_z();
    }else{
      for(int i = 0; i < nBots; i++){
        control_xy_nonWiFi(i);
      }
    }
  }
  
  //println("zControl: " + zControl.getValue() + "xySpeed: " + xySpeed.getValue() + "zSpeed: " + zSpeed.getValue());
  xy = map(xySpeed.getValue(), 50, 100, 0.8, 1.2);
  z = map(zSpeed.getValue(), 50, 100, 0.5, 1.5);
  //println("z: " + z + "xy: " + xy);
}
