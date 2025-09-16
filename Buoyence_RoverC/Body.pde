String left = "none";
String right = "none";
float leftArmAngle = 0;
float rightArmAngle = 0;
String walkingStatus = "not walking";
String currentState = "none"; 
boolean initializedBody = true;
boolean camera_hand = false;
boolean camera_body = false;
float targetY3, targetY2, targetY5, targetY6, targetY0, targetY1, targetY7, targetY8;

float[][] positions = {
  {90, 100}, {100, 150},  {110, 30},  {120, 80}, {140, 200},
  {160, 80}, {170, 30}, {180, 150}, {190, 100}
};
float[] y = new float[9];
float rightlength = dist(positions[8][0], positions[8][1], positions[7][0], positions[7][1]);
float leftlength = dist(positions[1][0], positions[1][1], positions[0][0], positions[0][1]);
float[][] currentPositions;

void BodyTracking(int id) {
  if(initializedBody){
    bodyX[id] = lerp(bodyX[id], positions[id][0] * 10 - 400, speed);
    bodyY[id] = lerp(bodyY[id], 4.5575714, speed);
    bodyZ[id] = lerp(bodyZ[id], positions[id][1] * 5 - 30, 0.01);  
    if (abs(bodyX[id] -  (positions[id][0] * 10 - 400)) < 10 && 
        abs(bodyZ[id] -  (positions[id][1] * 5 - 30)) < 10 &&  abs(bodyY[id] - 4.5575714) < 0.5 && key == 'g'){
       initializedBody = false;
    }
  }
  else{
    if(camera_body){
      updateArmPositions(id);
      updateWalkingStatus(id);
      //walkingStatus = "walking";
    }
  }
}

void updateArmPositions(int id) {
  if(id == 8){
    bodyX[8] = lerp(bodyX[8], bodyX[7] + rightlength * cos(radians(rightArmAngle)) * 10, speed);
    bodyZ[8] = lerp(bodyZ[8], bodyZ[7] + rightlength * sin(radians(rightArmAngle)) * 5, 0.01);
  } else if(id == 0) {
    bodyX[0] = lerp(bodyX[0], bodyX[1] - leftlength * cos(radians(leftArmAngle)) * 10, speed);
    bodyZ[0] = lerp(bodyZ[0], bodyZ[1] + leftlength * sin(radians(leftArmAngle)) * 5, 0.01);
  }
}

void updateWalkingStatus(int id) {
  if (walkingStatus.equals("walking")) {
    float legAmplitude = 15 * 30 * 2;
    float armAmplitude = 10 * 30 * 2;
    float walkingSpeed = 0.001;
    if(id == 2){
      targetY2 = + legAmplitude * cos(millis() * walkingSpeed) * 3 / 2;
      bodyY[2] = lerp(bodyY[2], targetY2, speed);
    }
    if(id == 3){
      targetY3 = + legAmplitude * cos(millis() * walkingSpeed);
      bodyY[3] = lerp(bodyY[3], targetY3, speed);
    }
    if(id == 5){
      targetY5 = - legAmplitude * cos(millis() * walkingSpeed);
      bodyY[5] = lerp(bodyY[5], targetY5, speed);
    } 
    if(id == 6){
      targetY6 = targetY5 * 3 / 2;
      bodyY[6] = lerp(bodyY[6], targetY6, speed);
    }
    if(id == 0){
      targetY0 = - armAmplitude * sin(millis() * walkingSpeed);
      bodyY[0] = lerp(bodyY[0], targetY0, speed * 1.8);
    }
    if(id == 1){
      targetY1 = - armAmplitude * sin(millis() * walkingSpeed) * 3 / 5;
      bodyY[1] = lerp(bodyY[1], targetY1, speed * 1.8);
    }
    if(id == 7){
      targetY7 = armAmplitude * cos(millis() * walkingSpeed) * 3 / 5;
      bodyY[7] = lerp(bodyY[7], targetY7, speed * 1.8);
    }
    if(id == 8){
      targetY8 = armAmplitude * cos(millis() * walkingSpeed);
      bodyY[8] = lerp(bodyY[8], targetY8, speed * 1.8);
    }
  } else {
    if(id == 2 || id == 3 || id == 5 || id == 6 || id == 0 || id == 1 || id == 7 || id == 8){
      bodyY[id] = lerp(bodyY[id], 0, speed);
    }
  }
}
