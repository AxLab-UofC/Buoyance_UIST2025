/* -------------------------------------------------------------------------- */
/*                         Toggle and button methods                         */
/* -------------------------------------------------------------------------- */

// toggle mode
void toggleMode(boolean theFlag)
{
  if(theFlag==true) { 
    modeControl = false;
  } else {
    modeControl = true;
  }
}

void controlEvent(ControlEvent event) {
  if (event.isFrom("targetingMode")) {
    if (event.getValue() == 0) {
      targetingMode = false;
      //println("Directional Input selected");
    } else if (event.getValue() == 1) {
      targetingMode = true;
      //println("Targeting selected");
    }
  }
}

// toggle tracking
void toggleTracking(boolean theFlag)
{
  if(theFlag==true) {
    trackingMode = false;
  } else {
    trackingMode = true;
    for(int i = 0; i < nBalloons; i++){
      balloons[i].translateObject(new PVector(omnibots[i].getPosition().x,omnibots[i].getPosition().y,zControl.getValue()),
                                                 yawControl.getValue() - balloons[selectedObject].yaw,
                                                 rollControl.getValue() - balloons[selectedObject].roll,
                                                 pitchControl.getValue() - balloons[selectedObject].pitch);   
    }
  }
}

// toggle driving
void toggleDrive(boolean theFlag)
{
  if(theFlag==true) {
    mouseControl = false;
  } else {
    mouseControl = true;
  }
  //println("drive: "+mouseControl);
}

void joystickDrive(boolean theFlag)
{
  if(theFlag==true) {
    joystickControl = false;
  } else {
    joystickControl = true;
  }
}

void dataDrive(boolean theFlag)
{
  if(theFlag==true) {
    dataControl = false;
    objectXYControl = balloons[selectedObject].objectCenter;
    zControl.setValue(balloons[selectedObject].objectCenter.z);
  } else {
    dataControl = true;
    for(RigBot bot : bots){
      bot.isActive = true;
    }
    for(int i = 0; i < nBalloons; i++){
      dataX[i] = balloons[i].objectCenter.x;
      dataY[i] = balloons[i].objectCenter.y;
      dataZ[i] = balloons[i].objectCenter.z;
    }
  }
}

void bodyDrive(boolean theFlag)
{
  if(theFlag==true) {
    bodyControl = false;
    objectXYControl = balloons[selectedObject].objectCenter;
    zControl.setValue(balloons[selectedObject].objectCenter.z);
  } else {
    bodyControl = true;
    if(gesture){
      for(RigBot bot : bots){
        bot.isActive = true;
      }
      for(int i = 0; i < nBalloons; i++){
        gestureX_sum[i] = balloons[i].objectCenter.x;
        gestureY_sum[i] = balloons[i].objectCenter.y;
        gestureZ_sum[i] = balloons[i].objectCenter.z;
      }
    }
    else{
      if(bodyControl_display){
        for(RigBot bot : bots){
          bot.isActive = true;
        }
      }
      for(int i = 0; i < nBalloons; i++){
        bodyX[i] = balloons[i].objectCenter.x;
        bodyY[i] = balloons[i].objectCenter.y;
        bodyZ[i] = balloons[i].objectCenter.z;
      }
    }
  }
}

// toggle lifting
void toggleLifting(boolean theFlag)
{
  if(theFlag==true) {
    lifting[selectedObject] = 0;
  } else {
    lifting[selectedObject] = 1;
  }
}

// toggle assembly
void toggleAssembly(boolean theFlag)
{
  if(theFlag==true) {
    assembly = false;
     //** initialize combined balloon **//
    combinedBalloons.clear();
    for(int i = 0; i < nBalloons; i++){
      ArrayList<Balloon> selectedBalloons = new ArrayList<Balloon>();
      selectedBalloons.add(balloons[i]);
      CombinedBalloon combinedBalloon = new CombinedBalloon(i, selectedBalloons);
      combinedBalloons.add(combinedBalloon);
    }
    
    // Change XYZ and angles values of GUI to match object
    // Change yaw and roll
    // Change XYZ speed
    InitXYZControl(balloons[selectedObject], botHeight);
  } else {
    assembly = true;
    for (CombinedBalloon combinedBalloon : combinedBalloons) {
      combinedBalloon.updateConnectionPoints();
      combinedBalloon.objectCenter = combinedBalloon.computeObjectCenter(combinedBalloon.connections);
    }
    // Change XYZ and angles values of GUI to match object
    // Change yaw and roll
    // Change XYZ speed
    InitXYZControl(combinedBalloons.get(selectedCombinedObject),combinedBalloons.get(selectedCombinedObject).getMinHeight());
  }
  //println("drive: "+mouseControl);
}

// change selected objects
void toggleObject(int theValue) {
  if(assembly){
    for (ConnectionPoint c : combinedBalloons.get(selectedCombinedObject).connections)
    {
      c.bot.isActive = false;
    }
    combinedBalloons.get(selectedCombinedObject).isActive = false;
    selectedCombinedObject += theValue;
    selectedCombinedObject %= combinedBalloons.size();
    
    for (ConnectionPoint c : combinedBalloons.get(selectedCombinedObject).connections)
    {
      c.bot.isActive = true;
    }
    combinedBalloons.get(selectedCombinedObject).isActive = true;
    
    // Change XYZ and angles values of GUI to match object
    InitXYZControl(combinedBalloons.get(selectedCombinedObject),combinedBalloons.get(selectedCombinedObject).getMinHeight());
  }else{
    for (ConnectionPoint c : balloons[selectedObject].connections)
    {
      c.bot.isActive = false;
    }
    balloons[selectedObject].isActive = false;
    //println("button event: ");
    selectedObject += theValue;
    selectedObject %= nBalloons;
    
    for (ConnectionPoint c : balloons[selectedObject].connections)
    {
      c.bot.isActive = true;
    }
    balloons[selectedObject].isActive = true;
    
    // Change XYZ and angles values of GUI to match object
    // Change yaw and roll
    // Change XYZ speed
    InitXYZControl(balloons[selectedObject],botHeight);
  }
}
