class CombinedBalloon extends Balloon
{
  public PVector previousObjectCenter;
  ArrayList<Balloon> selectedBalloons = new ArrayList<Balloon>();
  
  public CombinedBalloon(int id, ArrayList<Balloon> selectedBalloons){
    super(id, true, new ConnectionPoint[0]);
    previousObjectCenter = new PVector (0,0);
    
    this.selectedBalloons = selectedBalloons;
    this.updateConnectionPoints();
    this.objectCenter = computeObjectCenter(this.connections);
  }
  
  
  /* -------------------------------------------------------------------------- */
  /*                            main drive funtion                              */
  /* -------------------------------------------------------------------------- */ 

  @Override
  public void translateObject(PVector newObjectCenter, float newYaw, float newRoll, float newPitch){
    if(abs(newYaw) > 5) this.yaw += newYaw;
    if(abs(newRoll) > 5) this.roll += newRoll;
    if(abs(newPitch) > 5) this.pitch += newPitch;
    
    PVector dist = PVector.sub(newObjectCenter, objectCenter);
    //println("delta:"+distz +"new:"+newz +"obj:"+objectCenter.z );

    //update new positions
    this.objectCenter = newObjectCenter;

    // update connection points linked to this object
    for (ConnectionPoint c : this.connections)
    {
      RigBot bot = c.bot;

      // updates coordinates using distx,y,z, newyaw, pitch, roll and objectCenter
      c.translatePoint(dist);
      c.rotatePoint(newYaw, newRoll, newPitch, this.objectCenter, this.yaw, this.slopeAngle);

      // x, y distances from object center
      float x = c.getCenter().x - this.objectCenter.x;
      float y = c.getCenter().y - this.objectCenter.y;
      
      //bot.updateOffset(this.offset, x,y);
      //updates the matrices of the rigbot based on 6 dof changes
      if(keyPressed && key == 'd'){
        float radius = 600;
        createDisassembledCircle(radius);
      }
      bot.updateXYZ(c.getCenter());
    }
    for (Balloon selectedBalloon : selectedBalloons) {
      //selectedBalloon.objectCenter.add(dist);
      selectedBalloon.objectCenter = selectedBalloon.connections[0].center;
      selectedBalloon.yaw = this.yaw;
      selectedBalloon.roll = this.roll;
      selectedBalloon.pitch = this.pitch;
      selectedBalloon.slopeAngle = this.slopeAngle;
    }
  }
  
  /* -------------------------------------------------------------------------- */
  /*                              helper funtions                               */
  /* -------------------------------------------------------------------------- */
  
  //*** check rotation ***//
  public void checkRotation(float tolerance) {
    // ** calculate best fit line for multiple connection points ** //
    float sumX = 0;
    float sumY = 0;
    float sumXY = 0;
    float sumXX = 0;
    int n = connections.length;
  
    for (ConnectionPoint c : connections) {
      sumX += c.center.x;
      sumY += c.center.y;
      sumXY += c.center.x * c.center.y;
      sumXX += c.center.x * c.center.x;
    }
  
    float slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    float intercept = (sumY - slope * sumX) / n;
    
    slopeAngle = degrees(atan(slope));
    
    // ** check if the connection points are in tolerance and set state ** //
    if(connections.length == 1){
      this.state = 0;
    }else{
      float averageDistance = 0;
      for(ConnectionPoint c : connections){
        float distance = abs(slope * c.center.x - c.center.y + intercept) / sqrt(sq(slope) + 1);
        averageDistance += distance;
      }
      averageDistance /= connections.length;
      
      if(averageDistance <= tolerance){
        this.state = 1;
      }else{
        this.state = 2;
      }
    }
  }
  
   ArrayList<CombinedBalloon> setCombinedBalloons(){
    float combinedBalloonPosXInView = ((this.objectCenter.x-stageWidth/2-stageCenterX)/matScale)+stageWidth/2;
    float combinedBalloonPosYInView = ((this.objectCenter.y-stageDepth/2-stageCenterY)/matScale)+stageDepth/2;
    if(mousePressed && mouseButton == LEFT && keyPressed && keyCode == ALT){
      float dist = (new PVector(mouseInView.x - combinedBalloonPosXInView, mouseInView.y - combinedBalloonPosYInView)).mag();
      if(dist < 16){
        if(this.id != selectedCombinedObject){
          CombinedBalloon selectedCombinedBalloon = combinedBalloons.get(selectedCombinedObject);
          selectedCombinedBalloon.selectedBalloons.addAll(this.selectedBalloons);
          selectedCombinedBalloon.updateConnectionPoints();
          selectedCombinedBalloon.objectCenter = selectedCombinedBalloon.computeObjectCenter(selectedCombinedBalloon.connections);
          for(ConnectionPoint c : selectedCombinedBalloon.connections){
            c.bot.isActive = true;
          }
          selectedCombinedBalloon.checkRotation(tolerance);
          ArrayList<CombinedBalloon> tmpCombinedBalloons = combinedBalloons;
          tmpCombinedBalloons.remove(this);
          this.id = selectedCombinedObject = tmpCombinedBalloons.indexOf(selectedCombinedBalloon);
          return tmpCombinedBalloons;
        }
      }
    }
    return null;
  }
  
  void updateConnectionPoints() {
    ArrayList<ConnectionPoint> tempList = new ArrayList<ConnectionPoint>();
    for (Balloon balloon : selectedBalloons) {
      for (ConnectionPoint c : balloon.connections) {
        if (c != null) {
          tempList.add(c);
        }
      }
    }
    connections = new ConnectionPoint[tempList.size()];
    tempList.toArray(connections);
  }
  
  float getMinHeight(){
    float minHeight = botHeight;
    float distCenter = 0;
    for(Balloon balloon : selectedBalloons){
      distCenter = this.objectCenter.z - balloon.objectCenter.z;
      if(minHeight < botHeight - distCenter){
        minHeight = botHeight - distCenter;
      }
    }
    return minHeight;
  }
  
  /* -------------------------------------------------------------------------- */
  /*                 forming circle disassemble fuction                         */
  /* -------------------------------------------------------------------------- */
  void createDisassembledCircle(float radius){
    ArrayList<PVector> circlePositions = new ArrayList<PVector>();
    ArrayList<Boolean> isTargetOccupied= new ArrayList<Boolean>();
    float angleStep = TWO_PI/selectedBalloons.size();
    
    for(int i = 0; i < connections.length; i++){
      float angle = i * angleStep;
      float x = radius * cos(angle);
      float y = radius * sin(angle);
      //circlePositions.add((new PVector(x,y,this.objectCenter.z)).add(this.objectCenter));
      circlePositions.add((new PVector(x,y,0)).add(new PVector(this.objectCenter.x, this.objectCenter.y, botHeight)));
      isTargetOccupied.add(false);
    }
    
    for(ConnectionPoint c: connections){
      PVector closestTarget = findClosestAvailableTarget(c.center, circlePositions, isTargetOccupied);
      c.center = closestTarget;
    }
  }
  
  PVector findClosestAvailableTarget(PVector objectCenter, ArrayList<PVector> circlePositions, ArrayList<Boolean> isTargetOccupied) {
    PVector closest = null;
    float minDist = Float.MAX_VALUE;
    
    for (int i = 0; i < selectedBalloons.size(); i++) {
      PVector targetPos = circlePositions.get(i);
      if (!isTargetOccupied.get(i)) {
        float dist = objectCenter.dist(targetPos);
        if (dist < minDist) {
          minDist = dist;
          closest = targetPos;
        }
      }
    }
    
    if (closest != null) {
      int index = circlePositions.indexOf(closest);
      isTargetOccupied.set(index, true);
    }
    
    return closest;
  }
}
