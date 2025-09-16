///** MAIN function to visualize everything **///
//Visuals
void displayDebug() {
  background(0);
  stroke(255);

  if (!enable3Dview) {
    fill(255);
    textSize(12);
    text("FPS = " + frameRate, 10, height-10);//Displays how many clients have connected to the server
    display2D();
  } else {
    if (keyPressed && key == ' ') {
      cam.setMouseControlled(true);
    } else {
      cam.setMouseControlled(false);
    }
    // display 3D
    display3D();

    cam.beginHUD();
    display2D();
    if (!targetingMode) {
      drawArrays();
    }
    if (debugView) {
      debugFor3DView();
      debugFortracking();
      if (assembly) {
        debugForRotation(combinedBalloons.get(selectedCombinedObject).state);
      }//else{
      //debugForRotation(balloons[selectedObject].state);
      //}
      if (nObstacles > 0) {
        debugForAvoidance();
      }
    }
    cam.endHUD();
  }
}


/* --------------------------------------------------------------------------*/
/*                               Display 3D                                  */
/* ------------------------------------------------------------------------- */
///** function to show everything in 3D **///
void display3D() {
  //stage lets see how to roate it together
  pushMatrix();
  //rotateX(radians(30));
  //rotateX(radians(250));
  rotateX(radians(90));
  translate(-600, -200, -300);
  //drawMainStage();
  pushMatrix();
  translate(stageCenterX, stageCenterY, 0);
  drawTrimmingStage(stageWidth*matScale, stageDepth*matScale);
  popMatrix();
  drawMainStage();
  //Axis
  pushMatrix();
  translate(-stageWidth/2, -stageDepth/2, 2);
  drawAxis();

  // draw RigBots
  if ((!dataControl || (dataControl && dataControl_debug)) && (!bodyControl || (bodyControl && bodyControl_debug && bodyControl_display) || (bodyControl && !bodyControl_display))) {
    renderRigBots();
  }

  // draw Obstacles
  if (nObstacles != 0) {
    for (int i = 0; i < nObstacles; i++) {
      drawObstacle(i, obstacles[i]);
    }
  }

  // Drawing targets and string lines
  for (CombinedBalloon combinedBalloon : combinedBalloons) {
    if (assembly) {
      drawBalloonAxis(combinedBalloon.objectCenter, combinedBalloon.yaw, combinedBalloon.roll, combinedBalloon.slopeAngle, (combinedBalloon.id == selectedCombinedObject));
    }
    for (Balloon balloon : combinedBalloon.selectedBalloons) {
      boolean highlight = false;
      if (gesture && nHands == 4 && gesture_status == 0) {
        if ((tracking_gesture[1] == false && balloon.id == selectedObject_1) || (tracking_gesture[3] == false && balloon.id == selectedObject_2)) {
          highlight = true;
        }
      } else if (!dataControl && !(bodyControl && bodyControl_display) && !(gesture && gesture_status != 0)) {
        if (assembly) {
          highlight = (combinedBalloon.id == selectedCombinedObject);
        } else {
          highlight = (balloon.id == selectedObject);
        }
      } else {
        highlight = true;
      }

      // draw target object
      drawTarget3D(balloon.id, balloon.objectCenter.x, balloon.objectCenter.y, balloon.objectCenter.z, highlight);

      //draw string lines and attachment plane
      if ((!dataControl || (dataControl && dataControl_debug)) && (!bodyControl || (bodyControl && bodyControl_debug && bodyControl_display) || (bodyControl && !bodyControl_display))) {
        stroke(255, 255, 255, 100); // define stroke color (R,G,B, alpha) -- all between 0-255
        strokeWeight(5);

        for (ConnectionPoint p : balloon.connections)
        {
          line(p.bot.omnibot.position.x, p.bot.omnibot.position.y, p.bot.omnibot.position.z + botHeight, p.getCenter().x, p.getCenter().y, p.getCenter().z);

          for (ConnectionPoint q : balloon.connections) {
            if (q.id > p.id) {
              line(q.getCenter().x, q.getCenter().y, q.getCenter().z, p.getCenter().x, p.getCenter().y, p.getCenter().z);
            }
          }
        }
      }
    }
  }

  if (bodyControl && hand) {
    drawHand();
  }
  if (bodyControl && gesture && nHands == 2) {
    drawGestureRight(tracking_gesture[1]);
  }
  if (bodyControl && gesture && nHands == 4) {
    drawGestureLeft(tracking_gesture[3]);
    drawGestureRight(tracking_gesture[1]);
  }

  popMatrix();
  popMatrix();
}

///** Debug info **///
void debugFor3DView() {
  //control GUI
  cp5.draw();

  fill(255);
  textSize(20);
  if (!dataControl) {
    text("Hold 'SPACE' + Drag to Rotate the 3D Model \nHold 'd' to remove the debug view. \nSelected object: " + selectedObject, 20, 30);
  } else {
    text("Hold 'SPACE' + Drag to Rotate the 3D Model \nHold 'd' to remove the debug view.", 20, 30);
  }
}

void debugFortracking() {
  textSize(20);
  if (!tracking_robot) {
    fill(255, 0, 0);
    text("Loss Tracking For Robots", 20, 130);
  } else {
    fill(0, 255, 0);
    text("Success Tracking for Robots", 20, 130);
  }
}

void debugForRotation(int state) {
  textSize(20);
  if (!dataControl) {
    if (state == 0) {
      fill(255, 0, 0); // Red color
      text("Pitch, Yaw, and Roll \ncan not be implemented", 20, 170);
    } else if (state == 1) {
      fill(255, 165, 0); // Orange color
      text("Roll can not be implemented", 20, 130);
    } else if (state == 2) {
      fill(0, 255, 0); // Green color
      text("Pitch, Yaw, and Roll \nare fully implemented", 20, 170);
    }
  }
}

void debugForAvoidance() {
  // Display Target Avoidance Status
  if (avoid == 0) {
    fill(0, 255, 0);  // Set fill color to green
    text("Target Avoidance: \nSuccessful Targeted", 20, 250);
  } else if (avoid == -2) {
    fill(255, 0, 0);  // Set fill color to red
    text("Target Avoidance: \nError - Collision with Other Bots", 20, 250);
  } else if (avoid == -1) {
    fill(255, 0, 0);  // Set fill color to red
    text("Target Avoidance: \nError - Collision with Obstacles", 20, 250);
  }
}

void display2D() {
  pg2D.beginDraw();
  pg2D.background(0, 45, 90, 255);
  pg2D.pushMatrix();
  pg2D.translate(pg2D.width/2, pg2D.height/2);
  pg2D.scale(1/matScale);
  pg2D.translate(-stageCenterX-stageWidth/2, -stageCenterY-stageDepth/2);
  draw2DMat();
  pg2D.popMatrix();
  if (nObstacles != 0) {
    for (int i = 0; i < nObstacles; i++) {
      drawObstacle2D(i, obstacles[i]);
    }
  }
  for (CombinedBalloon combinedBalloon : combinedBalloons) {
    boolean combinedHightlight = (combinedBalloon.id == selectedCombinedObject);
    for (Balloon balloon : combinedBalloon.selectedBalloons) {
      boolean highlight = false;
      if (gesture && nHands == 4 && gesture_status == 0) {
        if ((tracking_gesture[1] == false && balloon.id == selectedObject_1) || (tracking_gesture[3] == false && balloon.id == selectedObject_2)) {
          highlight = true;
        }
      } else if (!dataControl && !(bodyControl && bodyControl_display) && !(gesture && gesture_status != 0)) {
        if (assembly) {
          highlight = (combinedBalloon.id == selectedCombinedObject);
        } else {
          highlight = (balloon.id == selectedObject);
        }
      } else {
        highlight = true;
      }
      for (ConnectionPoint c : balloon.connections)
      {
        draw2DRoverC(balloon.id, ((c.bot.omnibot.position.x-stageWidth/2-stageCenterX)/matScale)+stageWidth/2, ((c.bot.omnibot.position.y-stageDepth/2-stageCenterY)/matScale)+stageDepth/2, c.bot.omnibot.yaw, highlight);
      }
      if (targetingMode) {
        drawTarget2D(balloon.id, ((balloon.objectCenter.x-stageWidth/2-stageCenterX)/matScale)+stageWidth/2, ((balloon.objectCenter.y-stageDepth/2-stageCenterY)/matScale)+stageDepth/2, omnibots[balloon.id].targetSet, highlight);
      }
    }
    if (assembly) {
      drawCombinedTarget2D(combinedBalloon.id, ((combinedBalloon.objectCenter.x-stageWidth/2-stageCenterX)/matScale)+stageWidth/2, ((combinedBalloon.objectCenter.y-stageDepth/2-stageCenterY)/matScale)+stageDepth/2, combinedHightlight);
    }
  }
  pg2D.endDraw();

  image(pg2D, XYViewCoordX, XYViewCoordY); // Adjust the position based on the group position
}

/* --------------------------------------------------------------------------*/
/*                            DRAWING METHODS                                */
/* ------------------------------------------------------------------------- */
//draw object at (x,y,z) method
void drawTarget3D(int id, float x, float y, float z, boolean selected) {
  pushMatrix();
  translate(x, y, z);
  if (selected) {
    fill(255, 0, 0);
  } else {
    fill(0, 0, 255);
  }
  noStroke();

  if (dataControl || (bodyControl && bodyControl_display)) {
    pushMatrix();
    translate(0, 0, balloonSize/2);
    sphere(balloonSize / 2);
    popMatrix();
  } else {
    pushMatrix();
    rotateZ(radians(balloons[id].yaw + balloons[id].slopeAngle));
    rotateY(radians(balloons[id].pitch));
    rotateX(radians(balloons[id].roll));
    translate(0, 0, balloonSize/2);
    //sphere(balloonSize / 2);
    box(balloonSize);
    drawCubeEdges(balloonSize);
    popMatrix();
  }

  textSize(12);
  rotateX(radians(90));
  text("3D target " + id + " [" + x + ", " + y + ", " + z + "]", 15, 0);
  popMatrix();
}

void drawCubeEdges(float w) {
  PVector[] vertices = {
    new PVector(-w/2, -w/2, -w/2),
    new PVector(w/2, -w/2, -w/2),
    new PVector(w/2, w/2, -w/2),
    new PVector(-w/2, w/2, -w/2),
    new PVector(-w/2, -w/2, w/2),
    new PVector(w/2, -w/2, w/2),
    new PVector(w/2, w/2, w/2),
    new PVector(-w/2, w/2, w/2),
  };

  int[][] edges = {
    {0, 1}, {1, 2}, {2, 3}, {3, 0}, // front face
    {4, 5}, {5, 6}, {6, 7}, {7, 4}, // back face
    {0, 4}, {1, 5}, {2, 6}, {3, 7}  // connecting edges
  };

  stroke(15);
  strokeWeight(1);

  for (int i = 0; i < edges.length; i++) {
    PVector v1 = vertices[edges[i][0]];
    PVector v2 = vertices[edges[i][1]];
    line(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
  }
}

void drawSphereEdges(float r) {
  int numEdges = 4;
  stroke(100, 200);
  strokeWeight(1);

  for (int i = 0; i < numEdges; i++) {
    float angle = TWO_PI / numEdges * i;

    beginShape();
    for (float theta = -HALF_PI; theta <= HALF_PI; theta += 0.1) {
      float x = r * cos(theta) * cos(angle);
      float y = r * sin(theta);
      float z = r * cos(theta) * sin(angle);
      vertex(x, y, z);
    }
    endShape();
  }
}

void drawBalloonAxis(PVector center, float yaw, float roll, float slopeAngle, boolean selected) {
  if (selected) {
    stroke(200, 150);
  } else {
    stroke(200, 0);
  }
  strokeWeight(3);
  pushMatrix();
  translate(center.x, center.y, center.z + balloonSize/2);
  rotateZ(radians(yaw+slopeAngle));
  rotateX(radians(roll));
  line(0, -200, 0, 0, 200, 0);
  popMatrix();
}

void drawTarget2D(int id, float x, float y, boolean targetingComplete, boolean selected) {
  int alpha = targetingComplete? 255 : 150;
  pg2D.pushMatrix();
  pg2D.translate(x, y);
  pg2D.fill(255);
  pg2D.textSize(20);
  pg2D.text(id, 0, -20);
  if (selected) {
    pg2D.fill(255, 0, 0, alpha);
  } else {
    pg2D.fill(0, 0, 255, alpha);
  }
  pg2D.ellipse(0, 0, 20, 20);
  pg2D.popMatrix();
  pg2D.strokeWeight(1);
}

void drawCombinedTarget2D(int id, float x, float y, boolean selected) {
  int alpha = selected? 255 : 120;
  int strokeWidth = selected? 4 : 2;
  pg2D.pushMatrix();
  pg2D.translate(x, y);
  pg2D.fill(255);
  pg2D.textSize(20);
  pg2D.text(id, 0, -20);
  pg2D.stroke(0, 255, 0, alpha);
  pg2D.strokeWeight(strokeWidth);
  pg2D.line(0, -20, 0, 20);
  pg2D.line(-20, 0, 20, 0);
  pg2D.popMatrix();
  pg2D.strokeWeight(1);
}

//draw toios and inBetweenMats togeter
void renderRigBots() {
  for (RigBot bot : bots) {
    OmniBot omnibot = bot.omnibot;
    drawRoverC(omnibot.position.x, omnibot.position.y, omnibot.position.z, omnibot.yaw);
    //drawCylinder(omnibot.position.x, omnibot.position.y, omnibot.position.z, omnibot.yaw);
  }
}

void drawToio(float x, float y, float z, float deg) {
  pushMatrix();
  stroke(200);
  strokeWeight(1);
  fill(255);
  translate(x, y, z + 10);
  rotate(radians(deg));
  box(23, 23, 19);
  stroke(255, 0, 0);
  strokeWeight(2);
  line(13, 0, 10, 5, 0, 10);
  popMatrix();
}

void drawRoverC(float x, float y, float z, float deg) {
  pushMatrix();
  translate(x, y, z + 7*mmToToio);
  rotate(deg);
  drawTire();
  translate(0, 0, 64.3*mmToToio/2 + 21*mmToToio);
  stroke(100);
  strokeWeight(1);
  fill(50);
  box(52.4*mmToToio, 94*mmToToio, 64.3*mmToToio);
  stroke(255, 0, 0);
  strokeWeight(2);
  line(13, 0, 10, 5, 0, 10);
  popMatrix();
}

void drawTire() {
  pushMatrix();
  translate(-21*mmToToio, 16*mmToToio, 7*mmToToio);
  rotateX(PI/2);
  rotateY(PI/2);
  drawCylinder(30, 14*mmToToio, 13.7*mmToToio);
  popMatrix();

  pushMatrix();
  translate(21*mmToToio, 16*mmToToio, 7*mmToToio);
  rotateX(PI/2);
  rotateY(PI/2);
  drawCylinder(30, 14*mmToToio, 13.7*mmToToio);
  popMatrix();

  pushMatrix();
  translate(-21*mmToToio, -16*mmToToio, 7*mmToToio);
  rotateX(PI/2);
  rotateY(PI/2);
  drawCylinder(30, 14*mmToToio, 13.7*mmToToio);
  popMatrix();

  pushMatrix();
  translate(21*mmToToio, -16*mmToToio, 7*mmToToio);
  rotateX(PI/2);
  rotateY(PI/2);
  drawCylinder(30, 14*mmToToio, 13.7*mmToToio);
  popMatrix();
}

void draw2DRoverC(int id, float x, float y, float yaw, boolean selected) {
  pg2D.pushMatrix();
  pg2D.translate(x, y);
  //pg2D.scale(1/matScale);
  //pg2D.strokeWeight(1*matScale);
  pg2D.fill(255);
  pg2D.textSize(20);
  pg2D.text(id, 0, -35);
  pg2D.noFill();
  if (selected) {
    //pg2D.fill(255, 0, 0, 255);
    pg2D.stroke(255, 0, 0);
  } else {
    //pg2D.fill(0,170,255,255);
    pg2D.stroke(0, 170, 255);
  }
  pg2D.rotate(yaw);
  pg2D.rect(-15, -15, 30, 30);
  //pg2D.rect(-omnibots[id].size/2, -omnibots[id].size/2, omnibots[id].size,omnibots[id].size);
  //pg2D.line(0, 0, 0, -omnibots[id].size);
  pg2D.line(0, 0, 0, -35);
  pg2D.strokeWeight(1);
  pg2D.popMatrix();
}

void draw2DMat() {
  pg2D.stroke(255, 60);
  pg2D.strokeWeight(3);
  for (int i = -10; i <= 10; i++) {
    pg2D.line(stageWidthMax/6 * (i), -stageDepthMax, stageWidthMax/6 * (i), stageDepthMax);
  }
  for (int i = -10; i <= 10; i++) {
    pg2D.line(stageWidthMax, stageDepthMax/6 * (i), -stageWidthMax, stageDepthMax/6* (i));
  }
  pg2D.stroke(255, 0, 0, 80);
  pg2D.line(0, 0, stageWidthMax, 0);
  pg2D.stroke(0, 255, 0, 80);
  pg2D.line(0, 0, 0, stageDepthMax);
  pg2D.strokeWeight(1);
}

void drawCylinder(float x, float y, float z, float deg) {
  pushMatrix();
  translate(x, y, z + 23);
  rotate(radians(deg));
  drawCylinder(100, 17, botHeight);
  popMatrix();
}

// cylinder for roverC tire
void drawCylinder(int sides, float r, float h)
{
  float angle = 360 / sides;
  float halfHeight = h / 2;

  fill(50);
  // draw top of the tube
  beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex( x, y, -halfHeight);
  }
  endShape(CLOSE);

  // draw bottom of the tube
  beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex(x, y, halfHeight);
  }
  endShape(CLOSE);

  //
  stroke(255, 255, 0);
  // draw sides
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < sides + 1; i++) {
    float x = cos( radians( i * angle ) ) * r;
    float y = sin( radians( i * angle ) ) * r;
    vertex(x, y, halfHeight);
    vertex(x, y, -halfHeight);
  }
  endShape(CLOSE);
}

void drawMainStage() {
  //start to do translation
  pushMatrix();
  translate(-XYViewWidth/2, -XYViewHeight/2, 2);
  stroke(255, 30);
  for (int i = -10; i <= 10; i++) {
    line(stageWidthMax/10 * (i), -stageDepthMax, stageWidthMax/10 * (i), stageDepthMax);
  }

  for (int i = -10; i <= 10; i++) {
    line(stageWidthMax, stageDepthMax/10 * (i), -stageWidthMax, stageDepthMax/10* (i));
  }

  fill(255, 20);

  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      int matID = 1 + (j) + i*4;
      text("#" + matID, stageWidthMax/4 * (i), stageDepthMax/4 * (j)+50);
    }
  }

  //finish doing translations
  popMatrix();
}

void drawTrimmingStage(float stageWidth, float stageDepth) {
  noStroke();
  fill(MainStageColor);

  PShape s = createShape();
  s.beginShape();

  // Exterior part of shape drawing lines to form a rect
  s.vertex(-stageWidth/2, -stageDepth/2);
  s.vertex(stageWidth/2, -stageDepth/2);
  s.vertex(stageWidth/2, stageDepth/2);
  s.vertex(-stageWidth/2, stageDepth/2);
  s.vertex(-stageWidth/2, -stageDepth/2);

  // Finishing off shape
  s.endShape();

  shape(s);
}

//render scene axis
void drawAxis() {
  strokeWeight(2);
  stroke(255, 0, 0);
  line(0, 0, 0, 2000, 0, 0);
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 2000, 0);
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 2000);
}

// draw buttons for up, down, left, and right
void drawArrays() {
  // Draw equilateral triangles in four directions
  drawTriangle(directionalButtonCenterX, directionalButtonCenterY - directionalButtonGap, directionalButtonSize, DirectionalState.UP);
  drawTriangle(directionalButtonCenterX, directionalButtonCenterY + directionalButtonGap, directionalButtonSize, DirectionalState.DOWN);
  drawTriangle(directionalButtonCenterX - directionalButtonGap, directionalButtonCenterY, directionalButtonSize, DirectionalState.LEFT);
  drawTriangle(directionalButtonCenterX + directionalButtonGap, directionalButtonCenterY, directionalButtonSize, DirectionalState.RIGHT);
}

void drawTriangle(float x, float y, float size, DirectionalState state) {
  float h = size * sqrt(3) / 2; // Height of the equilateral triangle
  fill(buttonPressed[state.ordinal()] ? color(255, 0, 0) : color(0, 170, 255)); // Red if pressed, white if not
  noStroke();
  beginShape();
  switch(state) {
  case UP:
    vertex(x, y - h / 2);
    vertex(x - size / 2, y + h / 2);
    vertex(x + size / 2, y + h / 2);
    break;
  case DOWN:
    vertex(x, y + h / 2);
    vertex(x - size / 2, y - h / 2);
    vertex(x + size / 2, y - h / 2);
    break;
  case LEFT:
    vertex(x - h / 2, y);
    vertex(x + h / 2, y - size / 2);
    vertex(x + h / 2, y + size / 2);
    break;
  case RIGHT:
    vertex(x + h / 2, y);
    vertex(x - h / 2, y - size / 2);
    vertex(x - h / 2, y + size / 2);
    break;
  }
  endShape(CLOSE);
}

void drawGestureRight(boolean open) {
  pushMatrix();
  translate(gestureX[0], gestureY[0], gestureZ_init[0]);
  rotateX(PI/2);
  rotateZ(PI);
  if(open){
    image(openHand, 0, 0, 100, 100);
  } else if(!open){
    image(closedHand, 0, 0, 100, 100);
  }
  popMatrix();
}

void drawGestureLeft(boolean open) {
  pushMatrix();
  translate(gestureX[2], gestureY[2], gestureZ_init[2]);
  rotateX(PI/2);
  rotateZ(PI);
  if(open){
    image(openRightHand, 0, 0, 100, 100);
  } else if(!open){
    image(closedRightHand, 0, 0, 100, 100);
  }
  popMatrix();
}

// draw hand for hand tracking
void drawHand() {
  PVector center = new PVector(handX, handY, handZ); // Center of the hand
  float handHeightScale = 0.7;  // Further scale down the height and size
  float handSizeScale = 0.8;  // Scaling factor for the overall size
  PVector wrist = new PVector(0, 0, 100 * handHeightScale * handSizeScale);
  PVector thumbBase = new PVector(-40 * handSizeScale, 0, 20 * handHeightScale * handSizeScale);
  PVector thumbTip = new PVector(-70 * handSizeScale, 0, -20 * handHeightScale * handSizeScale);
  PVector indexBase = new PVector(-20 * handSizeScale, 0, 20 * handHeightScale * handSizeScale);
  PVector indexMid = new PVector(-20 * handSizeScale, 0, -40 * handHeightScale * handSizeScale);
  PVector indexTip = new PVector(-20 * handSizeScale, 0, -100 * handHeightScale * handSizeScale);
  PVector middleBase = new PVector(0, 0, 20 * handHeightScale * handSizeScale);
  PVector middleMid = new PVector(0, 0, -50 * handHeightScale * handSizeScale);
  PVector middleTip = new PVector(0, 0, -120 * handHeightScale * handSizeScale);
  PVector ringBase = new PVector(20 * handSizeScale, 0, 20 * handHeightScale * handSizeScale);
  PVector ringMid = new PVector(20 * handSizeScale, 0, -40 * handHeightScale * handSizeScale);
  PVector ringTip = new PVector(20 * handSizeScale, 0, -100 * handHeightScale * handSizeScale);
  PVector pinkyBase = new PVector(40 * handSizeScale, 0, 20 * handHeightScale * handSizeScale);
  PVector pinkyMid = new PVector(40 * handSizeScale, 0, -30 * handHeightScale * handSizeScale);
  PVector pinkyTip = new PVector(40 * handSizeScale, 0, -80 * handHeightScale * handSizeScale);
  float angle = radians(- 180 + 45);
  wrist = rotateY(wrist, angle);
  thumbBase = rotateY(thumbBase, angle);
  thumbTip = rotateY(thumbTip, angle);
  indexBase = rotateY(indexBase, angle);
  indexMid = rotateY(indexMid, angle);
  indexTip = rotateY(indexTip, angle);
  middleBase = rotateY(middleBase, angle);
  middleMid = rotateY(middleMid, angle);
  middleTip = rotateY(middleTip, angle);
  ringBase = rotateY(ringBase, angle);
  ringMid = rotateY(ringMid, angle);
  ringTip = rotateY(ringTip, angle);
  pinkyBase = rotateY(pinkyBase, angle);
  pinkyMid = rotateY(pinkyMid, angle);
  pinkyTip = rotateY(pinkyTip, angle);
  translate(center.x, center.y, center.z);  // Center the hand at (200, 200, 200)
  // Draw the hand in grayscale in the x-z plane
  strokeWeight(4);
  float fixedY = 200;
  // Draw the thumb
  stroke(150);
  line(wrist.x, fixedY, wrist.z, thumbBase.x, fixedY, thumbBase.z);
  stroke(150);
  line(thumbBase.x, fixedY, thumbBase.z, thumbTip.x, fixedY, thumbTip.z);
  // Draw the index finger
  stroke(150);
  line(wrist.x, fixedY, wrist.z, indexBase.x, fixedY, indexBase.z);
  stroke(150);
  line(indexBase.x, fixedY, indexBase.z, indexMid.x, fixedY, indexMid.z);
  stroke(150);
  line(indexMid.x, fixedY, indexMid.z, indexTip.x, fixedY, indexTip.z);
  // Draw the middle finger
  stroke(150);
  line(wrist.x, fixedY, wrist.z, middleBase.x, fixedY, middleBase.z);
  stroke(150);
  line(middleBase.x, fixedY, middleBase.z, middleMid.x, fixedY, middleMid.z);
  stroke(150);
  line(middleMid.x, fixedY, middleMid.z, middleTip.x, fixedY, middleTip.z);
  // Draw the ring finger
  stroke(150);
  line(wrist.x, fixedY, wrist.z, ringBase.x, fixedY, ringBase.z);
  stroke(150);
  line(ringBase.x, fixedY, ringBase.z, ringMid.x, fixedY, ringMid.z);
  stroke(150);
  line(ringMid.x, fixedY, ringMid.z, ringTip.x, fixedY, ringTip.z);
  // Draw the pinky finger
  stroke(150);
  line(wrist.x, fixedY, wrist.z, pinkyBase.x, fixedY, pinkyBase.z);
  stroke(150);
  line(pinkyBase.x, fixedY, pinkyBase.z, pinkyMid.x, fixedY, pinkyMid.z);
  stroke(150);
  line(pinkyMid.x, fixedY, pinkyMid.z, pinkyTip.x, fixedY, pinkyTip.z);
}

PVector rotateY(PVector v, float angle) {
  float x = v.x * cos(angle) + v.z * sin(angle);
  float z = -v.x * sin(angle) + v.z * cos(angle);
  return new PVector(x, v.y, z);
}

// Function to draw an obstacle
void drawObstacle2D(int id, Obstacles obstacle) {
  if (obstacle.appear) {
    PVector position = obstacle.getPosition();
    float radius = (obstacle.size - 60) / matScale;

    // Define the alpha value (full opacity)
    int alpha = 255;

    // Push the current transformation matrix
    pg2D.pushMatrix();

    // Translate to the position of the obstacle
    pg2D.translate(((position.x-stageWidth/2-stageCenterX)/matScale)+stageWidth/2, ((position.y-stageDepth/2-stageCenterY)/matScale)+stageDepth/2);

    // Set the fill color to grey-white
    if (id == 2) {
      pg2D.fill(255, 255, 0, alpha);  // Yellow fill color
      pg2D.stroke(255, 255, 0);      // Yellow stroke color
    } else {
      pg2D.fill(220, 220, 220, alpha);  // Light gray fill color
      pg2D.stroke(169, 169, 169);       // Gray stroke color
    }

    // Set the stroke color and weight (optional)
    pg2D.stroke(169, 169, 169);  // Grey-white color for stroke
    pg2D.strokeWeight(2);

    // Draw the circle representing the obstacle
    pg2D.ellipse(0, 0, radius * 2, radius * 2);

    // Draw the dotted circle
    drawDottedCircle2D(radius + 15, 100);

    // Restore the original transformation matrix
    pg2D.popMatrix();

    // Reset the stroke weight
    pg2D.strokeWeight(1);
  }
}

// Function to draw a dotted circle in 2D
void drawDottedCircle2D(float r, int dotCount) {
  pg2D.stroke(0, 255, 0);
  float angleStep = TWO_PI / dotCount;
  for (int i = 0; i < dotCount; i++) {
    float x = cos(i * angleStep) * r;
    float y = sin(i * angleStep) * r;
    pg2D.point(x, y);  // Draw a point at the calculated position
  }
}

// Function to draw an obstacle
void drawObstacle(int id, Obstacles obstacle) {
  if (obstacle.appear) {
    pushMatrix();

    PVector pos = obstacle.getPosition();
    float radius = obstacle.size;

    translate(pos.x, pos.y, pos.z / 2);
    if (id == 2) {
      fill(255, 255, 0, 50);  // Yellow color with transparency for the fill
      stroke(255, 255, 0, 50); // Yellow color with transparency for the stroke
    } else {
      fill(169, 169, 169, 50);  // Gray color with transparency for the fill
      stroke(169, 169, 169, 50); // Gray color with transparency for the stroke
    }

    hint(DISABLE_DEPTH_TEST);
    drawCylinder_Ob(100, radius, pos.z);  // Draw the cylinder with sides = 100
    hint(ENABLE_DEPTH_TEST);

    // Draw a dotted circle around the cylinder
    drawDottedCircle(radius + 120, pos.z / 2, 150);  // Increase radius by 20 for the circle

    popMatrix();
  }
}

// Function to draw a cylinder
void drawCylinder_Ob(int sides, float r, float h) {
  float angle = 360.0 / sides;
  float halfHeight = h / 2.0;

  // Draw top of the cylinder
  beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos(radians(i * angle)) * r;
    float y = sin(radians(i * angle)) * r;
    vertex(x, y, -halfHeight);
  }
  endShape(CLOSE);

  // Draw bottom of the cylinder
  beginShape();
  for (int i = 0; i < sides; i++) {
    float x = cos(radians(i * angle)) * r;
    float y = sin(radians(i * angle)) * r;
    vertex(x, y, halfHeight);
  }
  endShape(CLOSE);

  // Draw sides of the cylinder with an outline
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < sides + 1; i++) {
    float x = cos(radians(i * angle)) * r;
    float y = sin(radians(i * angle)) * r;
    vertex(x, y, halfHeight);
    vertex(x, y, -halfHeight);
  }
  endShape(CLOSE);
}

// Function to draw a dotted circle
void drawDottedCircle(float r, float z, int dotCount) {
  stroke(0, 255, 0);
  strokeWeight(3);
  float angleStep = TWO_PI / dotCount;
  for (int i = 0; i < dotCount; i++) {
    float x = cos(i * angleStep) * r;
    float y = sin(i * angleStep) * r;
    point(x, y, -z);  // Draw a point at the calculated position
  }
}
