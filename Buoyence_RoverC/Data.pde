// Waves, Circle, Elephant, Giraffe, Human
int dataMode = -1; // -1 for initial state, 0 for starting, 1 for wave, 2 for circle, 3 for elephant, 4 for giraffe, 5 for opening

// Wave drawing function
// Wave variables
float waveSpeed = 0.001;
float waveFrequency = 0.1;
float waveOffset = 0;
float[] waveZ;
float phaseShift;
int stateWave = -1;
void drawWave(int id) {
   switch(stateWave) {
    case -1:
      phaseShift = id * PI / 4;
      waveZ[id] = 350 * sin(TWO_PI * waveFrequency * waveOffset + phaseShift) + 438.69482;
      dataX[id] = lerp(dataX[id], 5.751343 + 120 * (id - (nBalloons / 2)) * 3, 0.008);
      dataY[id] = lerp(dataY[id], 4.5575714, speed);
      dataZ[id] = lerp(dataZ[id], waveZ[id], 0.05);  
      boolean check_0 = true;
      for(int i = 0; i < nBalloons; i++){
         if (abs(dataX[i] - (5.751343 + 120 * (i - (nBalloons / 2)) * 3)) > 10 || 
             abs(dataZ[i] - waveZ[i]) > 10) {
           check_0 = false;
         }
      }
      if(check_0){
        stateWave = 0;
      }
      break;
    case 0:
      phaseShift = id * PI / 4;
      float targetY = 500 * sin(TWO_PI * waveFrequency * waveOffset + phaseShift);
      dataX[id] = lerp(dataX[id], 5.751343 + 120 * (id - (nBalloons / 2)) * 3, 0.01);
      dataY[id] = lerp(dataY[id], targetY, 0.01);  
      waveOffset += waveSpeed;
      break;
   }
}


// Circle drawing function
// Circle variables
float targetX;
float targetY;
float targetZ;
float bigCircleRadius = 900;
float smallCircleRadius = 300;  // Much smaller radius for the small balloon
float zHeight = 600;
float spiralSpeed = 0.0003;  // Slower spiral speed
float lerpAmount = 0;
float targetRadius, radius;
int stateCircle = -1;  // -1: initial move to large balloon, 0: moving to small balloon, 1: moving to large balloon
boolean initializedCircle = false;
void drawCircle(int id) {
  switch(stateCircle) {
    case -1: // Initial move to large balloon
      if (!initializedCircle) {
        float angle;
        int mov;
        if(nBalloons % 2 == 0){
          mov = nBalloons / 2;
        }
        else{
          mov = (nBalloons - 1) / 2;
        }
        if(id % 2 == 0){
          angle = TWO_PI * (id + mov - id / 2) / nBalloons;
        }
        else{
          angle = TWO_PI * ((nBalloons - 1 - id) + mov + (id + 1) / 2) / nBalloons;
        }
        dataX[id] = lerp(dataX[id], 5.751343 + bigCircleRadius * cos(angle), speed);
        dataY[id] = lerp(dataY[id], 4.5575714 + bigCircleRadius * sin(angle), speed);
        dataZ[id] = lerp(dataZ[id], zHeight, speed);
        if (abs(dataX[id] - (5.751343 + bigCircleRadius * cos(angle))) < 20 && 
            abs(dataY[id] - (4.5575714 + bigCircleRadius * sin(angle))) < 20) {
          stateCircle = 1;
          initializedCircle = true;
          // Set first target to small balloon
          int targetIndex = id;
          targetX = 5.751343 + smallCircleRadius * cos(TWO_PI * targetIndex / nBalloons);
          targetY = 4.5575714 + smallCircleRadius * sin(TWO_PI * targetIndex / nBalloons);
          targetZ = botHeight;
        }
      }
      break;
    case 0: // Moving to small balloon
      float currentRadius = dist(5.751343, 4.5575714, dataX[id], dataY[id]);
      targetRadius = dist(5.751343, 4.5575714, targetX, targetY);
      float angle = atan2(dataY[id] - 4.5575714, dataX[id] - 5.751343);
      // Determine spiral direction based on whether moving to a larger or smaller circle
      float spiralDirection = targetRadius < currentRadius ? 1 : -1;
      float spiralAngle = angle + spiralDirection * lerpAmount * spiralSpeed * PI;
      radius = lerp(currentRadius, targetRadius, speed);
      dataX[id] = 5.751343 + radius * cos(spiralAngle);
      dataY[id] = 4.5575714 + radius * sin(spiralAngle);
      dataZ[id] = lerp(dataZ[id], targetZ, speed);
      lerpAmount += speed;
      if(lerpAmount > 5){
        lerpAmount = 5;
      }
      if (abs(radius - targetRadius) < 20) {
        lerpAmount = 0;
        stateCircle = 1;
        // Set target to large balloon
        int targetIndex = id;
        targetX = 5.751343 + bigCircleRadius * cos(TWO_PI * targetIndex / nBalloons);
        targetY = 4.5575714 + bigCircleRadius * sin(TWO_PI * targetIndex / nBalloons);
        targetZ = zHeight;
      }
      break;
    case 1: // Moving to large balloon
      currentRadius = dist(5.751343, 4.5575714, dataX[id], dataY[id]);
      targetRadius = dist(5.751343, 4.5575714, targetX, targetY);
      angle = atan2(dataY[id] - 4.5575714, dataX[id] - 5.751343);
      // Determine spiral direction based on whether moving to a larger or smaller circle
      spiralDirection = targetRadius < currentRadius ? 1 : -1;
      spiralAngle = angle + spiralDirection * lerpAmount * spiralSpeed * PI;
      radius = lerp(currentRadius, targetRadius, speed); 
      dataX[id] = 5.751343 + radius * cos(spiralAngle);
      dataY[id] = 4.5575714 + radius * sin(spiralAngle);
      dataZ[id] = lerp(dataZ[id], targetZ, speed); 
      lerpAmount += speed;
      if(lerpAmount > 5){
        lerpAmount = 5;
      }
      if (abs(radius - targetRadius) < 20) {
        lerpAmount = 0; 
        stateCircle = 0;
        // Set target to small balloon
        int targetIndex = id;
        targetX = 5.751343 + smallCircleRadius * cos(TWO_PI * targetIndex / nBalloons);
        targetY = 4.5575714 + smallCircleRadius * sin(TWO_PI * targetIndex / nBalloons);
        targetZ = botHeight + 30;
      }
      break;
  } 
}


// Elephant drawing function
// Elephant variables
int[][] positionsElephantFirst = {
  {20, 35}, {35, 45}, {40, 60}, {55, 70}, {70, 60}, 
  {75, 20}, {80, 40}, {100, 40}, {105, 20}
};
int[][] positionsElephantSecond = {
  {20, 80}, {30, 65}, {45, 60}, {60, 70}, {70, 60}, 
  {75, 20}, {80, 40}, {100, 40}, {105, 20}
};
int stateElephant = -1;  // 0: moving to first image, 1: displaying first image, 2: moving to second image, 3: displaying second image
void drawElephant(int id) {
  switch(stateElephant) {
    case -1: // Initial move to first image
      dataX[id] = lerp(dataX[id], positionsElephantFirst[id][0] * 15 + 5.75134 - 250, speed);
      dataZ[id] = lerp(dataZ[id], positionsElephantFirst[id][1] * 16 - 240, 0.01);
      boolean check_1 = true;
      for(int i = 0; i < nBalloons; i++){
         if (abs(dataX[i] - (positionsElephantFirst[i][0] * 15 + 5.75134 - 250)) > 10 || 
             abs(dataZ[i] - (positionsElephantFirst[i][1] * 16 - 240)) > 10) {
           check_1 = false;
         }
      }
      /*
      if(check_1){
        stateElephant = 1;
      }*/
      break;
    /*
    case 0: // Moving to first image
      dataX[id] = lerp(dataX[id], positionsElephantFirst[id][0] * 15 + 5.75134 - 1250, speed);
      dataZ[id] = lerp(dataZ[id], positionsElephantFirst[id][1] * 16 - 240, 0.01);
      boolean check_2 = true;
      for(int i = 0; i < nBalloons; i++){
        if (abs(dataX[i] - (positionsElephantFirst[i][0] * 15 + 5.75134 - 1250)) > 80 || 
            abs(dataZ[i] - (positionsElephantFirst[i][1] * 16 - 240)) > 80) {
          check_2 = false;
        }
      }
      if(check_2){
        stateElephant = 1;
      }
      break;
    case 1: // Moving to second image
      dataX[id] = lerp(dataX[id], positionsElephantSecond[id][0] * 15 + 5.75134 - 1250, speed);
      dataZ[id] = lerp(dataZ[id], positionsElephantSecond[id][1] * 16 - 240, 0.01);
      boolean check_3 = true;
      for(int i = 0; i < nBalloons; i++){
        if (abs(dataX[i] - (positionsElephantSecond[i][0] * 15 + 5.75134 - 1250)) > 80 || 
            abs(dataZ[i] - (positionsElephantSecond[i][1] * 16 - 240)) > 80) {
          check_3 = false;
        }
      }
      if(check_3){
        stateElephant = 0;
      }
      break;
    */
  } 
  dataY[id] = lerp(dataY[id], 4.5575714, speed);
}


// Giraffe drawing function
// Giraffe variables
int[][] positionsGiraffeFirst = {
  {55, 170}, {65, 175}, {70, 150}, {75, 120}, {85, 80}, 
  {90, 20}, {95, 50}, {110, 50}, {115, 20}
};
int[][] positionsGiraffeSecond = {
  {15, 110}, {25, 120}, {35, 100}, {50, 80}, {70, 60}, 
  {90, 20}, {95, 50}, {110, 50}, {115, 20}
};
int stateGiraffe = -1;  // 0: moving to first image, 1: displaying first image, 2: moving to second image, 3: displaying second image
void drawGiraffe(int id) {
  switch(stateGiraffe) {
    case -1: // Initial move to first image
      dataX[id] = lerp(dataX[id], positionsGiraffeSecond[id][0] * 15 + 5.75134 - 250, speed);
      dataZ[id] = lerp(dataZ[id], positionsGiraffeSecond[id][1] * 9 - 120, 0.01);
      boolean check_1 = true;
      for(int i = 0; i < nBalloons; i++){
         if (abs(dataX[i] - (positionsGiraffeSecond[i][0] * 15 + 5.75134 - 250)) > 10 || 
             abs(dataZ[i] - (positionsGiraffeSecond[i][1] * 9 - 120)) > 10) {
           check_1 = false;
         }
      }
      /*
      if(check_1){
        stateGiraffe = 1;
      }*/
      break;
    /*
    case 0: // Moving to first image
      dataX[id] = lerp(dataX[id], positionsGiraffeFirst[id][0] * 15 + 5.75134 - 1250, speed);
      dataZ[id] = lerp(dataZ[id], positionsGiraffeFirst[id][1] * 10 - 120, 0.01);
      boolean check_2 = true;
      for(int i = 0; i < nBalloons; i++){
        if (abs(dataX[i] - (positionsGiraffeFirst[i][0] * 15 + 5.75134 - 1250)) > 80 || 
            abs(dataZ[i] - (positionsGiraffeFirst[i][1] * 10 - 120)) > 80) {
          check_2 = false;
        }
      }
      if(check_2){
        stateGiraffe = 1;
      }
      break;
    case 1: // Moving to second image
      dataX[id] = lerp(dataX[id], positionsGiraffeSecond[id][0] * 15 + 5.75134 - 1250, speed);
      dataZ[id] = lerp(dataZ[id], positionsGiraffeSecond[id][1] * 10 - 120, 0.01);
      boolean check_3 = true;
      for(int i = 0; i < nBalloons; i++){
        if (abs(dataX[i] - (positionsGiraffeSecond[i][0] * 15 + 5.75134 - 1250)) > 80 || 
            abs(dataZ[i] - (positionsGiraffeSecond[i][1] * 10 - 120)) > 80) {
          check_3 = false;
        }
      }
      if(check_3){
        stateGiraffe= 0;
      }
      break;
    */
  } 
  dataY[id] = lerp(dataY[id], 4.5575714, speed);
}


// Opening drawing function
// Open variables
float openSpeed = 0.006;
float openFrequency = 0.3;
float openOffset = 2;
float openphaseShift;
float[] openAngle;
float openRadius = 300;
int openMov;
int stateOpen = -1;
void drawOpening(int id){
  switch(stateOpen) {
    case -1: // Initial move to large balloon
        openAngle[id] = TWO_PI * ((id + 2) % nBalloons) / nBalloons;
        dataX[id] = lerp(dataX[id], 5.751343 + openRadius * cos(openAngle[id]), speed);
        dataY[id] = lerp(dataY[id], 4.5575714 + openRadius * sin(openAngle[id]), speed);
        dataZ[id] = lerp(dataZ[id], 438.69482, speed);
        if (abs(dataX[id] - (5.751343 + openRadius * cos(openAngle[id]))) < 20 && 
            abs(dataY[id] - (4.5575714 + openRadius * sin(openAngle[id]))) < 20) {
          stateOpen= 0;     
        }
        break;
      case 0:
        //openAngle[id] += 0.002;
        openAngle[id] += 0.004;
        dataX[id] = 5.751343 + openRadius * cos(openAngle[id]);
        dataY[id] = 4.5575714 + openRadius * sin(openAngle[id]);
        openphaseShift = id * PI / 4;
        dataZ[id] = lerp(dataZ[id], 300 * sin(TWO_PI * openFrequency * openOffset + openphaseShift) + 438.69482, speed);
        openOffset += openSpeed;
        break;
  }
}
