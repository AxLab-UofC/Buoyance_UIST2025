/* -------------------------------------------------------------------------- */
/*                                GUI elements                                */
/* -------------------------------------------------------------------------- */

///** GUI controls **///
void setupGUI() {
  
   cp5 = new ControlP5(this);
   PFont controlFont = createFont("arial", 13);
   PFont groupFont = createFont("arial", 20);
   int groupBarHeight = 30;

   // Calculate the positions and sizes for the buttons
   int guiWidth = width / 2;
   int guiX = width - guiWidth / 2; // Position the GUI closer to the right side of the screen

   // Calculate vertical positioning
   int middleY = height / 2;
   int groupSpacing = 10;
   int groupHeight = 100; // Adjust height as needed
   
   ///** Mode Selection **///
   Group modeToggles = cp5.addGroup("Mode Selection")
       .setFont(groupFont)
       .setBackgroundColor(color(0,64))
       .setBarHeight(groupBarHeight)
       .setBackgroundHeight(30) // Increase height to fully cover the text
       .setPosition(guiX - 320, middleY - groupHeight - groupSpacing - groupBarHeight * 2 - 195) // Shifted further left
       .setSize(240, groupHeight); 

   modeToggle = cp5.addToggle("toggleMode")
       .setLabel("RoverC vs Toio")
       .setFont(controlFont)
       .setPosition(10, 10)
       .setSize(50, 20)
       .setValue(true)
       .setMode(ControlP5.SWITCH)
       .moveTo(modeToggles);
    
   ///** Simulation **///
   Group simToggles = cp5.addGroup("Position Method")
       .setFont(groupFont)
       .setBackgroundColor(color(0,64))
       .setBarHeight(groupBarHeight)
       .setBackgroundHeight(30) // Increase height to fully cover the text
       .setPosition(guiX - 320, middleY - groupHeight - groupSpacing - groupBarHeight * 2 - 100) // Shifted further left
       .setSize(240, groupHeight); // Adjust size to cover text
  
   /*
   simToggle = cp5.addToggle("toggleTargeting")
       .setLabel("Toggle Targeting")
       .setFont(controlFont)
       .setPosition(10, 10)
       .setSize(50, 20)
       .setValue(true)
       .setMode(ControlP5.SWITCH)
       .moveTo(simToggles);*/
   
   simRadio = cp5.addRadioButton("targetingMode")
     .setPosition(10, 10) // Adjust position inside the group
     .setSize(25, 20)
     .setFont(controlFont)
     .setItemsPerRow(2)  // Arrange in a row
     .setSpacingColumn(100)
     .addItem("Direction Input", 0)
     .addItem("Targeting", 1)
     .setNoneSelectedAllowed(false) // At least one button should be selected
     .moveTo(simToggles);
   simRadio.activate(0); 
   for (Toggle t : simRadio.getItems()) {
    t.getCaptionLabel()
      .setFont(controlFont)
      .setSize(13) // Adjust font size to match controlFont
      .align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE)
      .setPadding(0, 5); // Adjust padding to position label below the button
   }

   ///** Tracking **///
   Group trackingToggles = cp5.addGroup("Tracking")
       .setFont(groupFont)
       .setBackgroundColor(color(0,64))
       .setBarHeight(groupBarHeight)
       .setBackgroundHeight(30) // Increase height to fully cover the text
       .setPosition(guiX - 320, middleY - groupHeight - groupSpacing - groupBarHeight * 2 + 5) // Shifted further left
       .setSize(240, groupHeight); // Adjust size to cover text
  
   trackingToggle = cp5.addToggle("toggleTracking")
       .setLabel("Toggle Tracking")
       .setFont(controlFont)
       .setPosition(10, 10)
       .setSize(50, 20)
       .setValue(true)
       .setMode(ControlP5.SWITCH)
       .moveTo(trackingToggles);

   ///** Object Selection **///
   Group objectToggles = cp5.addGroup("Object Selection")
       .setFont(groupFont)
       .setBarHeight(groupBarHeight)
       .setBackgroundColor(color(0, 64))
       .setBackgroundHeight(20)
       .setPosition(guiX - 320, middleY - groupHeight - groupSpacing - groupBarHeight * 2 + 100) // Positioned higher
       .setSize(240, groupHeight); // Adjust size as needed
  
   selectButton = cp5.addButton("toggleObject")
      .setLabel("Select Object")
      .setFont(controlFont)
      .setValue(1)
      .setPosition(20, 15)
      .setSize(200,20)
      .moveTo(objectToggles);

   ///** Control Methods **///
   Group controlToggles = cp5.addGroup("Control Method")
       .setFont(groupFont)
       .setBarHeight(groupBarHeight)
       .setBackgroundColor(color(0, 64))
       .setBackgroundHeight(20)
       .setPosition(guiX - 320, middleY - groupHeight - groupSpacing - groupBarHeight * 2 + 195) // Positioned higher
       .setSize(240, groupHeight); // Adjust size as needed

   mouseToggle = cp5.addToggle("toggleDrive")
       .setLabel("Mouse Drive")
       .setFont(controlFont)
       .setPosition(10, 10)
       .setSize(50, 20)
       .setValue(true)
       .setMode(ControlP5.SWITCH)
       .moveTo(controlToggles);
   
   joystickToggle = cp5.addToggle("joystickDrive")
       .setLabel("Joystick Drive")
       .setFont(controlFont)
       .setPosition(120, 10)
       .setSize(50, 20)
       .setValue(true)
       .setMode(ControlP5.SWITCH)
       .moveTo(controlToggles);
   
   dataToggle = cp5.addToggle("dataDrive")
       .setLabel("Data Drive")
       .setFont(controlFont)
       .setPosition(10, 60)
       .setSize(50, 20)
       .setValue(true)
       .setMode(ControlP5.SWITCH)
       .moveTo(controlToggles);
       
   bodyToggle = cp5.addToggle("bodyDrive")
       .setLabel("BodyTracking")
       .setFont(controlFont)
       .setPosition(120, 60)
       .setSize(50, 20)
       .setValue(true)
       .setMode(ControlP5.SWITCH)
       .moveTo(controlToggles);
   
   ///** Applications **///
   Group applicationToggles = cp5.addGroup("UTILITIES")
       .setFont(groupFont)
       .setBarHeight(groupBarHeight)
       .setBackgroundColor(color(0, 64))
       .setBackgroundHeight(30)
       .setPosition(guiX - 320, middleY - groupHeight - groupSpacing - groupBarHeight * 2 + 285) // Positioned higher
       .setSize(240, groupHeight); // Adjust size as needed
   
   liftingToggle = cp5.addToggle("toggleLifting")
       .setLabel("Lifting")
       .setFont(controlFont)
       .setPosition(10, 10)
       .setSize(50, 20)
       .setValue(true)
       .setMode(ControlP5.SWITCH)
       .moveTo(applicationToggles);
   
   assemblyToggle = cp5.addToggle("toggleAssembly")
       .setLabel("Multi HIB Control")
       .setFont(controlFont)
       .setPosition(10, 60)
       .setSize(50, 20)
       .setValue(true)
       .setMode(ControlP5.SWITCH)
       .moveTo(applicationToggles);
   
   ///** Pitch, Yaw, Roll **///
   Group rotation = cp5.addGroup("Rotation")
       .setFont(groupFont)
       .setBarHeight(groupBarHeight)
       .setBackgroundColor(color(0, 64))
       .setBackgroundHeight(20)
       .setPosition(guiX - 70, middleY - groupHeight - groupSpacing - groupBarHeight * 2 + 345) // Positioned higher
       .setSize(410, groupHeight); 
   
   pitchControl = cp5.addSlider("Pitch Control")
     .setPosition(0,10)
     //.setPosition(guiX - 70, middleY - groupHeight - groupSpacing - groupBarHeight * 2 + 245)
     .setSize(410,30)
     .setRange(-45,45) //objects[selectedObject].maxZ
     .setNumberOfTickMarks(21)
     .setValue(0)
     .moveTo(rotation);
   
   cp5.getController("Pitch Control").getValueLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0).setPaddingY(12);
   cp5.getController("Pitch Control").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0).setPaddingY(12);
   
   yawControl = cp5.addSlider("Yaw Control")
     .setPosition(0,70)
     //.setPosition(guiX - 70, middleY - groupHeight - groupSpacing - groupBarHeight * 2 + 285)
     .setSize(410,30)
     .setRange(-180,180) //objects[selectedObject].maxZ
     .setNumberOfTickMarks(21)
     .setValue(0)
     .moveTo(rotation);
   
   cp5.getController("Yaw Control").getValueLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0).setPaddingY(12);
   cp5.getController("Yaw Control").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0).setPaddingY(12);
   
   rollControl = cp5.addSlider("Roll Control")
     .setPosition(0,130)
     //.setPosition(guiX - 70, middleY - groupHeight - groupSpacing - groupBarHeight * 2 + 325)
     .setSize(410,30)
     .setRange(-45,45) //objects[selectedObject].maxZ
     .setNumberOfTickMarks(21)
     .setValue(0)
     .moveTo(rotation);
   
   cp5.getController("Roll Control").getValueLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0).setPaddingY(12);
   cp5.getController("Roll Control").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0).setPaddingY(12);
   
   ///** Speed: X-Y and Z **///
   Group speed = cp5.addGroup("Speed")
       .setFont(groupFont)
       .setBarHeight(groupBarHeight)
       .setBackgroundColor(color(0, 64))
       .setBackgroundHeight(20)
       .setPosition(guiX - 70, middleY - groupHeight - groupSpacing - groupBarHeight * 2 + 195) // Positioned higher
       .setSize(410, groupHeight); // Adjust size as needed
   
   xySpeed = cp5.addSlider("X-Y Speed Control")
     .setPosition(0,10)
     //.setPosition(guiX - 70, middleY - groupHeight - groupSpacing - groupBarHeight * 2 + 165)
     .setSize(410,30)
     .setRange(50,100) //objects[selectedObject].maxZ
     .setValue(75)
     .moveTo(speed);
   
   cp5.getController("X-Y Speed Control").getValueLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
   cp5.getController("X-Y Speed Control").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
   
   zSpeed = cp5.addSlider("Z Speed Control")
     .setPosition(0,60)
     //.setPosition(guiX - 70, middleY - groupHeight - groupSpacing - groupBarHeight * 2 + 205)
     .setSize(410,30)
     .setRange(50,100) //objects[selectedObject].maxZ
     .setValue(75)
     .moveTo(speed);
   
   cp5.getController("Z Speed Control").getValueLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
   cp5.getController("Z Speed Control").getCaptionLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
   
   ///** 2D view **///
   //Group translations = cp5.addGroup("2D View")
   //.setFont(groupFont)
   //.setBarHeight(groupBarHeight)
   //.setBackgroundColor(color(0, 64))
   //.setBackgroundHeight(240)
   //.setPosition(guiX - 150, middleY - groupHeight - groupSpacing - groupBarHeight * 2 - 280) // Above Mode Selection and Object Selection
   //.setSize(500, 240); // Same width as control method
   
   cp5.addTextlabel("2D View")
    .setText("2D View")
    .setFont(groupFont)
    .setPosition(guiX - 70, 5)
    .setSize(500, 240);
  
   //objectXYControl = cp5.addSlider2D("Object X-Y Control")
   //   .setFont(controlFont)
   //   .setPosition(10, 20)
   //   .setSize(400, 180) // Increased size
   //   .setMinMax(minCoordX, minCoordY, maxCoordX, maxCoordY)
   //   .setValue(balloons[selectedObject].objectCenter.x, balloons[selectedObject].objectCenter.y)
   //   .moveTo(translations);
   
   // Create the PGraphics object
   pg2D = createGraphics(XYViewWidth,XYViewHeight);
  
   zControl = cp5.addSlider("Z Control")
      .setPosition(guiX + 310, 30)
      .setSize(30, 360) // Increased size
      .setRange(botHeight,1200) // objects[selectedObject].maxZ
      .setValue(balloons[selectedObject].objectCenter.z);
      //.moveTo(translations);
  
   // Reposition the Label for controller 'slider'
   cp5.getController("Z Control").getValueLabel().align(ControlP5.RIGHT, ControlP5.RIGHT_OUTSIDE).setPaddingX(0);
   cp5.getController("Z Control").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
   
   cp5.addTextlabel("X-Y Control")
    .setText("X-Y Control")
    .setPosition(guiX - 70, 395)
    .setSize(cp5.getController("Z Control").getCaptionLabel().getWidth(), 
            cp5.getController("Z Control").getCaptionLabel().getHeight());
            
   ///** Add Accordion **///
   Accordion accordion_1 = cp5.addAccordion("acc_1")
     .setPosition(guiX - 320, middleY - groupHeight - groupSpacing - groupBarHeight * 2 - 225)
     .setWidth(240)
     .addItem(modeToggles)
     .addItem(simToggles)
     .addItem(trackingToggles)
     .addItem(objectToggles)
     .setItemHeight(50)
     .addItem(controlToggles)
     .addItem(applicationToggles);
     
   accordion_1.open(0, 1, 2, 3, 4, 5);
   accordion_1.setCollapseMode(Accordion.MULTI);
  
   Accordion accordion_2 = cp5.addAccordion("acc_2")
     .setPosition(guiX - 70, middleY - groupHeight - groupSpacing - groupBarHeight * 2 + 165)
     .setWidth(410)
     .addItem(speed)
     .setItemHeight(120)
     .addItem(rotation);
  
   accordion_2.open(0, 1);
   accordion_2.setCollapseMode(Accordion.MULTI);
   
   cp5.setAutoDraw(false);

   // camera
   cam = new PeasyCam(this, 400);
   cam.setDistance(1000);
   surface.setLocation(100, 100);
}
