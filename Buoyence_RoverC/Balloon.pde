public class Balloon
{
  public int id;
  public PVector objectCenter;
  public ConnectionPoint connections[];
  public float maxZ = Float.MAX_VALUE; // Largest Z value possible
  public boolean isActive;
  public float xySpeed, zSpeed;
  public float pitch, yaw, roll;
  public int state;
  public float slopeAngle;
  
  
  protected float offset;
  
  public Balloon(int id, boolean isActive, ConnectionPoint connections[]){
    this.id = id;
    this.connections = connections;
    this.objectCenter = computeObjectCenter(this.connections);
    this.xySpeed = 75.0;
    this.zSpeed = 75.0;
    this.pitch = 0.0;
    this.yaw = 0.0;
    this.roll = 0.0;
    this.slopeAngle = 0.0;
    this.state = 0;
    this.offset = 30;
    this.isActive = isActive;
    for (ConnectionPoint c : this.connections)
    {
      PVector cpCenter = c.bot.getLinkedPoint().getCenter().copy();
      c.bot.omnibot.setPosition(new PVector(cpCenter.x, cpCenter.y, 0.0));
    }
  }
  
/* -------------------------------------------------------------------------- */
/*                              helper funtions                               */
/* -------------------------------------------------------------------------- */
  // get center position
  protected PVector computeObjectCenter(ConnectionPoint[] cps) {
    float x_total = 0;
    float y_total = 0;
    float z_total = 0;

    for (ConnectionPoint c : cps)
    {
      x_total += c.getCenter().x;
      y_total += c.getCenter().y;
      z_total += c.getCenter().z;
    }
    return new PVector(x_total / float(cps.length), y_total / float(cps.length), z_total / float(cps.length));
  }  
  
  // update selected object controlling mouse clicked
   void updateSelectedObject(PVector mouseInView){
    float balloonPosXInView = ((this.objectCenter.x-stageWidth/2-stageCenterX)/matScale)+stageWidth/2;
    float balloonPosYInView = ((this.objectCenter.y-stageDepth/2-stageCenterY)/matScale)+stageDepth/2;
    if(mousePressed && mouseButton == LEFT && keyPressed && keyCode == CONTROL){
      float dist = (new PVector(mouseInView.x - balloonPosXInView, mouseInView.y - balloonPosYInView)).mag();
      if(dist < 16){
        balloons[selectedObject].isActive = false;
        for (ConnectionPoint c : balloons[selectedObject].connections)
        {
          c.bot.isActive = false;
        }
        selectedObject = id;
        InitXYZControl(balloons[selectedObject], botHeight);
        for (ConnectionPoint c : balloons[selectedObject].connections)
        {
          c.bot.isActive = true;
        }
        balloons[selectedObject].isActive = true;
      }
    }
  }
  
  
/* -------------------------------------------------------------------------- */
/*                            main drive funtion                              */
/* -------------------------------------------------------------------------- */ 
  public void translateObject(PVector newObjectCenter, float newYaw, float newRoll, float newPitch){
    if(abs(newYaw) > 5) this.yaw += newYaw;
    if(abs(newRoll) > 5) this.roll += newRoll;
    if(abs(newPitch) > 5) this.pitch += newPitch;
    
    PVector dist = PVector.sub(newObjectCenter, objectCenter);
    //print("delta:"+distz +"new:"+newz +"obj:"+objectCenter.z );

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
      bot.updateXYZ(c.getCenter());
    }
  }
}
