//Data for hands and robots

PVector[] prev_robot = new PVector[nBots];
int[] lastT_robot = new int[nBots];
PVector[] prev_gesture = new PVector[nHands];
int[] lastT_gesture = new int[nHands];
int[] fist_count = new int[nHands];

void oscEvent(OscMessage msg) {
  
  //OpitTrack 
  // Address Patterns in Position Tracking -> Assets -> Scripts -> OSC
  if (trackingMode && msg.checkAddrPattern("/robot")){
    // get the position data of a robot
    int id = msg.get(0).intValue();
    float pos_x = msg.get(1).floatValue();
    float pos_y = msg.get(2).floatValue();
    float pos_z = msg.get(3).floatValue();
    //float angle_x = msg.get(4).floatValue();
    float angle_y = msg.get(5).floatValue();
    //float angle_z = msg.get(6).floatValue();
    
    if(id < nBots){
      //omnibots[id].setPosition(new PVector(pos_x, -pos_z, pos_y-0.067).mult(1000*mmToToio));
      omnibots[id].setPosition(new PVector(pos_x, -pos_z, 0).mult(1000*mmToToio));
      omnibots[id].setAngle(radians(angle_y));
      //print("[" + id + "]");
      //println("(pos: " + pos_x + "," + pos_z + " yaw: " + angle_y + ")", millis() + "\n");
      
      PVector current_robot = new PVector(pos_x, -pos_z, 0).mult(1000 * mmToToio);
      int currentT = millis();
      if(prev_robot[id] != null){
          int elapsed = currentT - lastT_robot[id];
          if(elapsed >= 30 && elapsed <= 50){
            // Use a small epsilon for floating point comparison
            float threshold = 0;
            if(abs(PVector.dist(current_robot, prev_robot[id])) > threshold){
               tracking_robot = true;
            } else {
               tracking_robot = false;
            }
          }
      }
      if(prev_robot[id] == null || currentT - lastT_robot[id] >= 30){
          prev_robot[id] = current_robot.copy();
          lastT_robot[id] = currentT;
      }
    }
  }
  if (trackingMode && msg.checkAddrPattern("/hand")){
    float pos_x = msg.get(0).floatValue();
    float pos_y = msg.get(1).floatValue();
    float pos_z = msg.get(2).floatValue();
    //float angle_x = msg.get(3).floatValue();
    //float angle_y = msg.get(4).floatValue();
    //float angle_z = msg.get(5).floatValue();
    if(abs(handX - pos_x*1000*mmToToio) > 1 && abs(handY + pos_z*1000*mmToToio) > 1 && abs(handZ - (pos_y-0.557)*1000*mmToToio) > 1){
      handX = pos_x*1000*mmToToio;
      handY = -pos_z*1000*mmToToio;
      handZ = (pos_y-0.557)*1000*mmToToio;
      if(handZ <= botHeight){
        handZ = botHeight;
      }
    }
    //println(hand);
    //println("(pos: " + handX + "," + handY + "," + handZ);
  }
  if (trackingMode && msg.checkAddrPattern("/gesture")){
    int id = msg.get(0).intValue();
    float pos_x = msg.get(1).floatValue();
    float pos_y = msg.get(2).floatValue();
    float pos_z = msg.get(3).floatValue();
    //float angle_x = msg.get(4).floatValue();
    //float angle_y = msg.get(5).floatValue();
    //float angle_z = msg.get(6).floatValue();
    
    if(id < nHands){
      gestureX[id] = pos_x*1000*mmToToio;
      gestureY[id] = -pos_z*1000*mmToToio;
      gestureZ_init[id] = (pos_y-0.007)*1000*mmToToio;
      if(gestureZ_init[id] <= botHeight){
        gestureZ_init[id] = botHeight;
      }
    }
    // Checking whether could detect the marker on the finger
    if((nHands == 2 && id == 1) || (nHands == 4 && (id == 1 || id == 3))){
      PVector current_gesture = new PVector(gestureX[id], gestureY[id], gestureZ_init[id]);
      //println("pos: " + id + " " + gestureX[id] + "," + gestureY[id] + "," + gestureZ_init[id] +  ")", millis() +  "\n");
      int currentT = millis();
      if(prev_gesture[id] != null){
          int elapsed = currentT - lastT_gesture[id];
          //print("elapsed: " + currentT + " " + lastT_gesture[id] + "\n");
          if(elapsed >= 100 && elapsed <= 150){
            // Use a small epsilon for floating point comparison
            float threshold = 0;
            if(abs(PVector.dist(current_gesture, prev_gesture[id])) > threshold){
               fist_count[id] = 0;
            } else {
               fist_count[id] += 1;
            }
            if(fist_count[id] < 2){
              //print(id + " open\n");
              tracking_gesture[id] = true;
              gestureX_prev[id - 1] = 0;
              gestureY_prev[id - 1] = 0;
              gestureZ_prev[id - 1] = 0;
            }
            else {
              //print(id + " fist\n");
              tracking_gesture[id] = false;
            }
          }
      }
      if(prev_gesture[id] == null || currentT - lastT_gesture[id] >= 150){
          prev_gesture[id] = current_gesture.copy();
          lastT_gesture[id] = currentT;
          gestureX_prev[id - 1] = gestureX[id - 1];
          gestureY_prev[id - 1] = gestureY[id - 1];
          gestureZ_prev[id - 1] = gestureZ_init[id - 1];
      }
    }
  }
  //Obstacle
  if (trackingMode && msg.checkAddrPattern("/object")){
    // get the position data of an obstacle
    int id = msg.get(0).intValue();
    float pos_x = msg.get(1).floatValue();
    float pos_y = msg.get(2).floatValue();
    float pos_z = msg.get(3).floatValue();
    //float angle_x = msg.get(4).floatValue();
    //float angle_y = msg.get(5).floatValue();
    //float angle_z = msg.get(6).floatValue();
    
    if(id < nObstacles){
      obstacles[id].setPosition(new PVector(pos_x, -pos_z, pos_y-0.067).mult(1000*mmToToio));
    }
    //print("[" + id + "]");
    //println("(pos: " + pos_x + "," + pos_z + " yaw: " + angle_y + ")");
  }
  
  //Media Pipe
  if(bodyControl)
  {
    if (currentState.equals("hand")) {
      if (msg.checkAddrPattern("/hand_movement")) {
        camera_hand = true;
        String message = msg.get(0).stringValue();
        String[] movements = message.split(", ");
        for (String movement : movements) {
          if (movement.startsWith("left hand")) {
            left = movement.substring(10);
          } else if (movement.startsWith("right hand")) {
            right = movement.substring(11);
          }
        }
        //println("Left Hand: " + left + ", Right Hand: " + right);
      }
    } else if (currentState.equals("body")) {
      camera_body = true;
      if (msg.checkAddrPattern("/left_arm_angle")) {
        rightArmAngle = msg.get(0).floatValue();
        rightArmAngle = rightArmAngle * 2 / 3;
      } else if (msg.checkAddrPattern("/right_arm_angle")) {
        leftArmAngle = msg.get(0).floatValue();
        leftArmAngle = leftArmAngle * 2 / 3;
      } else if (msg.checkAddrPattern("/walking_status")) {
        walkingStatus = msg.get(0).stringValue();
      }
      //println("Left Arm: " + leftArmAngle + ", Right Arm: " + rightArmAngle + ", Walking: " + walkingStatus);
    }
  }
}

void sendState() {
  // Send the current state ("hand" or "body") to the Python server
  OscMessage msg = new OscMessage("/mode");
  msg.add(currentState);
  oscP5.send(msg, server[0]);
}
